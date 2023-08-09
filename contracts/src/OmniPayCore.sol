// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {IERC20} from "openzeppelin/token/ERC20/IERC20.sol";
import {Ownable} from "openzeppelin/access/Ownable.sol";
import {ILayerZeroEndpoint} from "LayerZero/interfaces/ILayerZeroEndpoint.sol";
import {ILayerZeroReceiver} from "LayerZero/interfaces/ILayerZeroReceiver.sol";
import {IExternalRouter} from "./interfaces/IExternalRouter.sol";

contract OmniPayCore is Ownable, ILayerZeroReceiver {
    mapping(address => uint256) public balances;
    mapping(uint16 => bytes) public trustedRemoteLookup;
    mapping(bytes32 => bool) public processed;
    mapping(uint16 => bool) public nonLayerZeroChains;

    IExternalRouter public externalRouter;
    ILayerZeroEndpoint public layerZeroEndpoint;
    IERC20 public usdc;

    constructor(address _usdc, address _layerZeroEndpoint) {
        usdc = IERC20(_usdc);
        layerZeroEndpoint = ILayerZeroEndpoint(_layerZeroEndpoint);
    }

    function deposit(address token, uint256 amount) external {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        balances[token] += amount;
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
        bytes32 hash = keccak256(abi.encodePacked(_srcChainId, _srcAddress, _nonce, _payload));
        if (processed[hash]) {
            return;
        }
        processed[hash] = true;

        if (msg.sender != address(layerZeroEndpoint) || msg.sender != address(externalRouter)) {
            return;
        }

        if (keccak256(_srcAddress) != keccak256(trustedRemoteLookup[_srcChainId])) {
            return;
        }

        (address from, uint256 amount, bool isDeposit) = abi.decode(_payload, (address, uint256, bool));

        if (isDeposit) {
            balances[from] += amount;
        } else {
            if (balances[from] < amount) {
                return;
            }
            balances[from] -= amount;
        }

        bytes memory remoteAndLocalAddresses = abi.encodePacked(_srcAddress, address(this));
        bytes memory payload = abi.encode(from, amount);

        address fromAddress;
        assembly {
            fromAddress := mload(add(_srcAddress, 20))
        }

        if (nonLayerZeroChains[_srcChainId]) {
            externalRouter.send(
                _srcChainId, remoteAndLocalAddresses, payload, payable(msg.sender), address(0x0), bytes("")
            );
            return;
        }

        (uint256 nativeFee,) = layerZeroEndpoint.estimateFees(_srcChainId, fromAddress, _payload, false, bytes(""));

        layerZeroEndpoint.send{value: nativeFee}(
            _srcChainId, remoteAndLocalAddresses, payload, payable(msg.sender), address(0x0), bytes("")
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

    function withdraw() external onlyOwner {
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "OmniPayCore: Withdraw failed");
    }

    receive() external payable {}
}
