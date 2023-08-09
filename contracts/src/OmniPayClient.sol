// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";
import {ILayerZeroEndpoint} from "LayerZero/interfaces/ILayerZeroEndpoint.sol";
import {ILayerZeroReceiver} from "LayerZero/interfaces/ILayerZeroReceiver.sol";

contract OmniPayClient is Ownable, ILayerZeroReceiver {
    event LzCall(uint16 srcChainId, bytes srcAddress, uint64 nonce, bytes payload);
    event HashAlreadyProcessed();
    event InvalidEndpoint();
    event LookupNotTrusted();

    mapping(uint16 => bytes) public trustedRemoteLookup;
    mapping(bytes32 => bool) public processed;

    ILayerZeroEndpoint public layerZeroEndpoint;
    IERC20 public usdc;
    address public coreAddress;
    uint16 public coreChainId;

    constructor(address _usdc, address _layerZeroEndpoint, address _coreAddress, uint16 _coreChainId) {
        usdc = IERC20(_usdc);
        layerZeroEndpoint = ILayerZeroEndpoint(_layerZeroEndpoint);
        coreAddress = _coreAddress;
        coreChainId = _coreChainId;
    }

    function deposit(uint256 amount) external {
        usdc.transferFrom(msg.sender, address(this), amount);

        _send(amount, true);
    }

    function withdraw(uint256 amount) external {
        _send(amount, false);
    }

    function _send(uint256 amount, bool isDeposit) internal {
        bytes memory payload = abi.encode(msg.sender, amount, isDeposit);
        bytes memory remoteAndLocalAddresses = abi.encodePacked(coreAddress, address(this));

        bytes memory adapterParams = isDeposit ? bytes("") : abi.encodePacked(uint16(1), uint256(500000));
        (uint256 nativeFee,) = layerZeroEndpoint.estimateFees(coreChainId, coreAddress, payload, false, adapterParams);
        layerZeroEndpoint.send{value: nativeFee}(
            coreChainId, remoteAndLocalAddresses, payload, payable(address(this)), address(0x0), adapterParams
        );
    }

    /// @notice This function should not revert, as it should not be blocking the future transfers.
    function lzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload)
        external
        override
    {
        emit LzCall(_srcChainId, _srcAddress, _nonce, _payload);
        bytes32 hash = keccak256(abi.encodePacked(_srcChainId, _srcAddress, _nonce, _payload));
        if (processed[hash]) {
            emit HashAlreadyProcessed();
            return;
        }
        processed[hash] = true;

        if (msg.sender != address(layerZeroEndpoint)) {
            emit InvalidEndpoint();
            return;
        }

        if (keccak256(_srcAddress) != keccak256(trustedRemoteLookup[_srcChainId])) {
            emit LookupNotTrusted();
            return;
        }

        (address to, uint256 amount) = abi.decode(_payload, (address, uint256));

        usdc.transfer(to, amount);
    }

    function setTrustedRemoteLookup(uint16 _srcChainId, bytes memory _srcAddress) external onlyOwner {
        trustedRemoteLookup[_srcChainId] = _srcAddress;
    }

    function setLayerZeroEndpoint(address _layerZeroEndpoint) external onlyOwner {
        layerZeroEndpoint = ILayerZeroEndpoint(_layerZeroEndpoint);
    }

    function setCoreAddress(address _coreAddress) external onlyOwner {
        coreAddress = _coreAddress;
    }

    function setCoreChainId(uint16 _coreChainId) external onlyOwner {
        coreChainId = _coreChainId;
    }

    function setUsdc(address _usdc) external onlyOwner {
        usdc = IERC20(_usdc);
    }

    function withdrawEth() external onlyOwner {
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "OmniPayClient: Withdraw failed");
    }

    receive() external payable {}
}
