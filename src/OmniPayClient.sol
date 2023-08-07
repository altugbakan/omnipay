// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";
import {ILayerZeroEndpoint} from "LayerZero/interfaces/ILayerZeroEndpoint.sol";
import {ILayerZeroReceiver} from "LayerZero/interfaces/ILayerZeroReceiver.sol";

contract OmniPayCore is Ownable, ILayerZeroReceiver {
    mapping(address => uint256) public balances;
    mapping(uint16 => bytes) public trustedRemoteLookup;
    mapping(bytes32 => bool) public processed;

    ILayerZeroEndpoint public layerZeroEndpoint;
    IERC20 public immutable usdc;
    address public coreAddress;
    uint16 public coreChainId;

    constructor(address _usdc, address _layerZeroEndpoint, address _coreAddress, uint16 _coreChainId) {
        usdc = IERC20(_usdc);
        layerZeroEndpoint = ILayerZeroEndpoint(_layerZeroEndpoint);
        coreAddress = _coreAddress;
        coreChainId = _coreChainId;
    }

    function deposit(address token, uint256 amount) external {
        IERC20(token).transferFrom(msg.sender, address(this), amount);

        bytes memory payload = abi.encode(msg.sender, amount, true);
        bytes memory remoteAndLocalAddresses = abi.encodePacked(coreAddress, address(this));

        (uint256 nativeFee,) = layerZeroEndpoint.estimateFees(coreChainId, coreAddress, payload, false, bytes(""));
        layerZeroEndpoint.send{value: nativeFee}(
            coreChainId, remoteAndLocalAddresses, payload, payable(msg.sender), address(0x0), bytes("")
        );
    }

    function withdraw(uint256 amount) external {
        bytes memory payload = abi.encode(msg.sender, amount, false);
        bytes memory remoteAndLocalAddresses = abi.encodePacked(coreAddress, address(this));

        (uint256 nativeFee,) = layerZeroEndpoint.estimateFees(coreChainId, coreAddress, payload, false, bytes(""));
        layerZeroEndpoint.send{value: nativeFee}(
            coreChainId, remoteAndLocalAddresses, payload, payable(msg.sender), address(0x0), bytes("")
        );
    }

    function withdrawNative(uint256 amount) external {
        balances[msg.sender] -= amount;
        usdc.transfer(msg.sender, amount);
    }

    /// @notice This function should not revert, as it should not be blocking the future transfers.
    function lzReceive(uint16 _srcChainId, bytes memory _srcAddress, uint64 _nonce, bytes memory _payload)
        external
        override
    {
        bytes32 hash = keccak256(abi.encodePacked(_srcChainId, _srcAddress, _nonce, _payload));
        if (processed[hash]) {
            return;
        }
        processed[hash] = true;

        if (msg.sender != address(layerZeroEndpoint)) {
            return;
        }

        if (keccak256(_srcAddress) != keccak256(trustedRemoteLookup[_srcChainId])) {
            return;
        }

        (address from, uint256 amount) = abi.decode(_payload, (address, uint256));

        balances[from] += amount;
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
}
