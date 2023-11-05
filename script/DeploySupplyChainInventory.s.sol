// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {SupplyChainInventory} from "../src/SupplyChainInventory.sol";

contract DeploySupplyChainInventory is Script {

    function run() external returns(SupplyChainInventory) {
        vm.startBroadcast();
        SupplyChainInventory supplyChainInventory = new SupplyChainInventory();
        vm.stopBroadcast();

        return supplyChainInventory;
    }
}

