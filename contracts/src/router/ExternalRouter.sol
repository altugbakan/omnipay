// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "openzeppelin/access/Ownable.sol";
import {ILayerZeroReceiver} from "LayerZero/interfaces/ILayerZeroReceiver.sol";
import {IExternalRouter} from "../interfaces/IExternalRouter.sol";

contract ExternalRouter is IExternalRouter, Ownable {
    struct Message {
        uint16 chainId;
        bytes addressCombination;
        bytes payload;
    }

    event MessageSent(Message message);

    Message[] public messageQueue;
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

        Message memory message = Message(_dstChainId, _destination, _payload);
        messageQueue.push(message);

        emit MessageSent(message);
    }

    function estimateFees(uint16, address, bytes calldata, bool, bytes calldata)
        external
        pure
        returns (uint256, uint256)
    {
        return (0, 0);
    }

    function queueLength() external view returns (uint256) {
        return messageQueue.length;
    }

    function route(Message calldata message) external onlyOwner {
        omniPay.lzReceive(
            message.chainId, message.addressCombination, ++lastNonces[message.addressCombination], message.payload
        );
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
