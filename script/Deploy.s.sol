// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "forge-std/Script.sol";
import "../contracts/FlashArbitrage.sol";
contract DeployScript is Script {
    function run() external {
        vm.startBroadcast(vm.envUint("PRIVATE_KEY"));
        FlashArbitrage arb = new FlashArbitrage();
        console.log("FlashArbitrage deployed:", address(arb));
        vm.stopBroadcast();
    }
}