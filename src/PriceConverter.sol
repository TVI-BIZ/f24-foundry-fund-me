// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {AggregatorV3Interface} from "@chainlink/contracts/AggregatorV3Interface.sol";

library PriceConverter {
    function getprice(
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        // Adress
        // ABI

        //address current_deployed_interface = 0x694AA1769357215DE4FAC081bf1f309aDC325306;
        //priceFeed = AggregatorV3Interface(current_deployed_interface);
        /* uint80 roundID */
        (, int price, , , ) = priceFeed.latestRoundData();
        return uint256(price * 10e10);
    }

    function getConversionRate(
        uint256 ethAmount,
        AggregatorV3Interface priceFeed
    ) internal view returns (uint256) {
        uint256 price = getprice(priceFeed);
        return (ethAmount * price) / 1e18;
    }
}
