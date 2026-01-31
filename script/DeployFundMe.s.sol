// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/Fundme.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
contract DeployFundMe is Script {
    function run() external returns (FundMe) {
        // before broadcast --> Not a real txn.
        HelperConfig helperConfig = new HelperConfig();
        // After broadcast --> Real txn.
        address ethusdpriceFeed = helperConfig.activeNetworkConfig();
        
        vm.startBroadcast();
        FundMe fundMe = new FundMe(ethusdpriceFeed);
        vm.stopBroadcast();
        return fundMe;
    }
}
