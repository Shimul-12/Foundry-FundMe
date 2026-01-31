// 1. deploy mocks when we are on a local anvil chain.
// 2. keep track of contract address across different chains.
// 3. easily switch between local anvil chain and testnet/mainnet chains.

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import {Script} from "forge-std/script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

// if we are on a local anvil chain, we deploy mocks.
// otherwise, we get the price feed address from the live network.
contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 18;
    int256 public constant INITIAL_PRICE = 2000e18;

    struct NetworkConfig {
        address priceFeed;
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getsepoliaethconfig();
        } else {
            activeNetworkConfig = getorcreateanvilConfig();
        }
    }

    function getsepoliaethconfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getorcreateanvilConfig() public returns (NetworkConfig memory) {
       //1. Deploy mocks
       //2. return the mock address
       vm.startBroadcast();
         MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE);
       vm.stopBroadcast ();

         NetworkConfig memory anvilConfig = NetworkConfig({
              priceFeed: address(mockPriceFeed)
         });
            return anvilConfig;
    }
}
