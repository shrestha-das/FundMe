// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

// it's NOT a contract
// it's a LIBRARY
library PriceConverter {
    function getPrice(AggregatorV3Interface dataFeed) internal view returns (uint256) {
        // address
        // ABI
        (, int256 answer,,,) = dataFeed.latestRoundData();
        // Price of ETH in terms of USD
        return uint256(answer * 1e10);
    }

    function getConversionRate(uint256 ethAmount, AggregatorV3Interface dataFeed) internal view returns (uint256) {
        uint256 ethPrice = getPrice(dataFeed);
        uint256 ethAmountinUSD = (ethPrice * ethAmount) / 1e18; // Amount in ETH
        return ethAmountinUSD;
    }

    function getVersion() internal view returns (uint256) {
        return AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419).version();
    }
}
