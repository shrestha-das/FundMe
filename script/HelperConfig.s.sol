// SPDX-License-Identifier: MIT

// 1. Deploy mocks when we are on a local anvil chain
// 2. Keep track of contract address across different chains

pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    // If we are on a local anvil chain, we deploy mocks
    // Otherwise, grab the existing address from the live network
    
    NetworkConfig public activeNetworkConfig;
    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_ANSWER = 2000e8;

    struct NetworkConfig {
        address dataFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        }
        else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } 
        else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getActiveNetworkConfig() external view returns (NetworkConfig memory)
    {
      return activeNetworkConfig;
    }


    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // data feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            dataFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
        });
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // data feed address
        NetworkConfig memory mainnetConfig = NetworkConfig({
            dataFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        });
        return mainnetConfig;
    }
   
    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        // data feed address

        if (activeNetworkConfig.dataFeed != address(0)) {
            return activeNetworkConfig;
        }

        // 1. deploy the mocks
        // 2. Return the mock address

        vm.startBroadcast();
        MockV3Aggregator mockDataFeed = new MockV3Aggregator(DECIMALS, INITIAL_ANSWER);
        vm.stopBroadcast();
        
        NetworkConfig memory anvilConfig = NetworkConfig({
            dataFeed: address(mockDataFeed)
        });
        return anvilConfig;
    }

}