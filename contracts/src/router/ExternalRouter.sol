// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import {Ownable} from "openzeppelin/access/Ownable.sol";
import {IExternalRouter} from "../interfaces/IExternalRouter.sol";

contract ExternalRouter is IExternalRouter, Ownable {
    event MessageSent(
        uint16 dstChainId,
        bytes destination,
        bytes payload,
        address refundAddress,
        address zroPaymentAddress,
        bytes adapterParams
    );

    bytes[] public messageQueue;
    address omniPayCore;

    constructor(address _omniPayCore) {
        omniPayCore = _omniPayCore;
    }

    function send(
        uint16 _dstChainId,
        bytes calldata _destination,
        bytes calldata _payload,
        address payable _refundAddress,
        address _zroPaymentAddress,
        bytes calldata _adapterParams
    ) external override {
        require(msg.sender == omniPayCore, "ExternalRouter: Only OmniPayCore can call this function");

        messageQueue.push(
            abi.encode(_dstChainId, _destination, _payload, _refundAddress, _zroPaymentAddress, _adapterParams)
        );

        emit MessageSent(_dstChainId, _destination, _payload, _refundAddress, _zroPaymentAddress, _adapterParams);
    }

    function route(uint16 _srcChainId, bytes calldata _srcAddress, uint64 _nonce, bytes calldata _payload)
        external
        onlyOwner
    {
        (bool success,) = omniPayCore.call(
            abi.encodeWithSignature("lzReceive(uint16,bytes,uint64,bytes)", _srcChainId, _srcAddress, _nonce, _payload)
        );
        require(success, "ExternalRouter: Call to lzReceive failed");
    }

    function pop() external onlyOwner {
        require(messageQueue.length > 0, "ExternalRouter: No messages in queue");

        messageQueue.pop();
    }

    function setOmniPayCore(address _omniPayCore) external onlyOwner {
        omniPayCore = _omniPayCore;
    }
}
