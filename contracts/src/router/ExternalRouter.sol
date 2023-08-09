// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "openzeppelin/access/Ownable.sol";
import {ILayerZeroReceiver} from "LayerZero/interfaces/ILayerZeroReceiver.sol";
import {IExternalRouter} from "../interfaces/IExternalRouter.sol";

contract ExternalRouter is IExternalRouter, Ownable {
    event MessageSent(uint16 dstChainId, bytes destination, bytes payload);

    bytes[] public messageQueue;
    uint16 public currentChainId;
    mapping(bytes => uint64) public lastNonces;
    ILayerZeroReceiver public omniPay;

    constructor(address _omniPay, uint16 _currentChainId) {
        omniPay = ILayerZeroReceiver(_omniPay);
        currentChainId = _currentChainId;
    }

    function send(
        uint16 _dstChainId,
        bytes calldata _destination,
        bytes calldata _payload,
        address payable,
        address,
        bytes calldata
    ) external override {
        require(msg.sender == address(omniPay), "ExternalRouter: Only OmniPay can call this function");

        messageQueue.push(abi.encode(_dstChainId, _destination, _payload));

        emit MessageSent(_dstChainId, _destination, _payload);
    }

    function estimateFees(uint16, address, bytes calldata, bool, bytes calldata)
        external
        pure
        returns (uint256, uint256)
    {
        return (0, 0);
    }

    function route(uint16 _srcChainId, bytes calldata _srcAddress, bytes calldata _payload) external onlyOwner {
        omniPay.lzReceive(_srcChainId, _srcAddress, ++lastNonces[_srcAddress], _payload);
    }

    function pop() external onlyOwner {
        require(messageQueue.length > 0, "ExternalRouter: No messages in queue");

        messageQueue.pop();
    }

    function setOmniPay(address _omniPay) external onlyOwner {
        omniPay = ILayerZeroReceiver(_omniPay);
    }

    function withdraw() external onlyOwner {
        (bool success,) = payable(msg.sender).call{value: address(this).balance}("");
        require(success, "ExternalRouter: Withdraw failed");
    }

    receive() external payable {}
}
