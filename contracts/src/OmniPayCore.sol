// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";
import {ILayerZeroEndpoint} from "LayerZero/interfaces/ILayerZeroEndpoint.sol";
import {ILayerZeroReceiver} from "LayerZero/interfaces/ILayerZeroReceiver.sol";
import {IExternalRouter} from "./interfaces/IExternalRouter.sol";

contract OmniPayCore is Ownable, ILayerZeroReceiver {
    event LzCall(uint16 srcChainId, bytes srcAddress, uint64 nonce, bytes payload);
    event HashAlreadyProcessed();
    event InvalidEndpoint();
    event LookupNotTrusted();
    event Deposited(address user, uint256 amount);
    event Withdrawn(address user, uint256 amount);
    event NotEnoughBalance();

    mapping(address => uint256) public balances;
    mapping(uint16 => bytes) public trustedRemoteLookup;
    mapping(bytes32 => bool) public processed;

    IExternalRouter public externalRouter;
    ILayerZeroEndpoint public layerZeroEndpoint;
    IERC20 public usdc;

    constructor(address _usdc, address _layerZeroEndpoint) {
        usdc = IERC20(_usdc);
        layerZeroEndpoint = ILayerZeroEndpoint(_layerZeroEndpoint);
    }

    function deposit(uint256 amount) external {
        usdc.transferFrom(msg.sender, address(this), amount);
        balances[msg.sender] += amount;
    }

    function withdraw(uint256 amount) external {
        balances[msg.sender] -= amount;
        usdc.transfer(msg.sender, amount);
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

        if (msg.sender != address(layerZeroEndpoint) && msg.sender != address(externalRouter)) {
            emit InvalidEndpoint();
            return;
        }

        if (keccak256(_srcAddress) != keccak256(trustedRemoteLookup[_srcChainId])) {
            emit LookupNotTrusted();
            return;
        }

        (address from, uint256 amount, bool isDeposit) = abi.decode(_payload, (address, uint256, bool));

        if (isDeposit) {
            balances[from] += amount;
            emit Deposited(from, amount);
            return;
        } else {
            if (balances[from] < amount) {
                emit NotEnoughBalance();
                return;
            }
            balances[from] -= amount;
            emit Withdrawn(from, balances[from]);
        }

        address fromAddress;
        assembly {
            fromAddress := mload(add(_srcAddress, 20))
        }

        bytes memory payload = abi.encode(from, amount);
        bytes memory remoteAndLocalAddresses = abi.encodePacked(fromAddress, address(this));

        if (msg.sender == address(externalRouter)) {
            externalRouter.send(
                _srcChainId, remoteAndLocalAddresses, payload, payable(address(this)), address(0x0), bytes("")
            );
            return;
        }

        (uint256 nativeFee,) = layerZeroEndpoint.estimateFees(_srcChainId, fromAddress, _payload, false, bytes(""));

        layerZeroEndpoint.send{value: nativeFee}(
            _srcChainId, remoteAndLocalAddresses, payload, payable(address(this)), address(0x0), bytes("")
        );
    }

    function setTrustedRemoteLookup(uint16 _srcChainId, bytes memory _srcAddress) external onlyOwner {
        trustedRemoteLookup[_srcChainId] = _srcAddress;
    }

    function setLayerZeroEndpoint(address _layerZeroEndpoint) external onlyOwner {
        layerZeroEndpoint = ILayerZeroEndpoint(_layerZeroEndpoint);
    }

    function setExternalRouter(address _externalRouter) external onlyOwner {
        externalRouter = IExternalRouter(_externalRouter);
    }

    function setUsdc(address _usdc) external onlyOwner {
        usdc = IERC20(_usdc);
    }

    function withdrawEth() external onlyOwner {
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "OmniPayCore: Withdraw failed");
    }

    receive() external payable {}
}
