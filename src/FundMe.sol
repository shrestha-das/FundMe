// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant MINIMUM_USD = 5e18; // 5 ETH ( = 5e18 wei)
    address[] private s_funders; // array of the funders' addresses
    mapping(address => uint256) private s_addressToAmountfunded; // mapping to know which funder funded how much?
    address public immutable i_owner;
    AggregatorV3Interface private s_dataFeed;

    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender must be the Owner!");
        if (msg.sender != i_owner) revert FundMe__NotOwner();
        _;
    }

    constructor(address dataFeed) {
        i_owner = msg.sender;
        s_dataFeed = AggregatorV3Interface(dataFeed);
    }

    function fund() public payable {
        // allows Users to send $ (minimum 5$)

        require(msg.value.getConversionRate(s_dataFeed) >= MINIMUM_USD, "minimum 5 ETH is required!");
        s_funders.push(msg.sender);
        s_addressToAmountfunded[msg.sender] += msg.value;
    }

    // A gas efficient withdraw function
    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;

        for (uint256 funderIndex = 0; funderIndex < fundersLength; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountfunded[funder] = 0;
        }

        s_funders = new address[](0);

        // payable(msg.sender).transfer(address(this).balance);
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "send failed");
        (bool success,) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    // A function to Withdraw the funds
    function withdraw() public onlyOwner {
        for (uint256 funderIndex = 0; funderIndex < s_funders.length; funderIndex++) {
            address funder = s_funders[funderIndex];
            s_addressToAmountfunded[funder] = 0;
        }

        s_funders = new address[](0);

        // payable(msg.sender).transfer(address(this).balance);
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "send failed");
        (bool success,) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    // What happens if someone sends this contract ETH without calling the fund function
    receive() external payable {
        fund();
    }

    fallback() external payable {
        fund();
    }

    function getVersion() public view returns (uint256) {
        return s_dataFeed.version();
    }

    /**
     * View / Pure functions (Getters)
     */
    function getAddressToAmountFunded(address fundingAddress) external view returns (uint256) {
        return s_addressToAmountfunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
