// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {OmniPayCore} from "../src/OmniPayCore.sol";

contract GeneralTest is Test {
    function setUp() public {}

    function testEncodePacked() public {
        assertEq(
            bytes(hex"0001000000000000000000000000000000000000000000000000000000000007a120"),
            abi.encodePacked(uint16(1), uint256(500000))
        );
    }
}
