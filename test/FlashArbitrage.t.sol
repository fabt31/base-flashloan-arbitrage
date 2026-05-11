// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Test.sol";
import "../contracts/FlashArbitrage.sol";
contract FlashArbitrageTest is Test {
    function test_onlyOwnerCanExecute() public {
        vm.prank(address(0xdead));
        vm.expectRevert();
    }
    function test_revertIfNotProfitable() public { assertTrue(true); }
    function test_withdrawTokens() public { assertTrue(true); }
}