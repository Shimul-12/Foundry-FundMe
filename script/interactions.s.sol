// SPDX-License-Identifier: MIT

// fund script
// withdraw script
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";

contract FundFundMe is Script {
    uint256 constant FUND_AMOUNT = 0.1 ether;

    function fundFundMe(address mostrecentDeployed) public {
        FundMe(payable(mostrecentDeployed)).fund{value: FUND_AMOUNT}();

        console.log("Funded FundMe contract with %s ETH", FUND_AMOUNT);
    }

    function run() external {
        address mostrecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        fundFundMe(mostrecentlyDeployed);
        vm.stopBroadcast();
    }
}

contract WithdrawFundMe is Script {
    function withdrawFundMe(address mostrecentDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostrecentDeployed)).withdraw();
        vm.stopBroadcast();
        console.log("Withdrew from FundMe contract");
    }

    function run() external {
        address mostrecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainid);
        vm.startBroadcast();
        withdrawFundMe(mostrecentlyDeployed);
        vm.stopBroadcast();
    }
}
