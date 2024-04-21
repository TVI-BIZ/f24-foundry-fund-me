//"SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

//Get Funds from user
//Withdraw funds
//Set a minimum funding value in USD.

//this is link with foundry-chainlink-toolkit
import {AggregatorV3Interface} from "@chainlink/contracts/AggregatorV3Interface.sol";
import {PriceConverter} from "./PriceConverter.sol";

//constant
//801227
//780860 - contsnt
//757701 - immutable

error FundMe__NotOwner();

contract FundMe {
    using PriceConverter for uint256;

    uint256 public constant minimumUsd = 5e18;
    address[] public s_funders;

    mapping(address => uint256) private s_addressToAmountFunded;
    address payable private immutable i_owner;
    AggregatorV3Interface private s_priceFeed;

    constructor(address priceFeed) {
        i_owner = payable(msg.sender);
        s_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function fund() public payable {
        require(
            msg.value.getConversionRate(s_priceFeed) >= minimumUsd,
            "didn't send enough money"
        ); //1e18=1ETH=1000000000000000000

        s_funders.push(msg.sender);
        s_addressToAmountFunded[msg.sender] += msg.value;
    }

    function getVersion() public view returns (uint256) {
        return s_priceFeed.version();
    }

    function cheaperWithdraw() public onlyOwner {
        uint256 fundersLength = s_funders.length;

        for (
            uint256 funderIndex = 0;
            funderIndex < fundersLength;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);

        (bool callSuccess, bytes memory dataReturned) = payable(msg.sender)
            .call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    function withdraw() public onlyOwner {
        for (
            uint256 funderIndex = 0;
            funderIndex < s_funders.length;
            funderIndex++
        ) {
            address funder = s_funders[funderIndex];
            s_addressToAmountFunded[funder] = 0;
        }
        s_funders = new address[](0);
        // Transfer vs call vs Send
        // payable(msg.sender).transfer(address(this).balance);
        (bool success, ) = i_owner.call{value: address(this).balance}("");
        require(success);
    }

    modifier onlyOwner() {
        //require(msg.sender==owner,"Sender is not the owner");
        if (msg.sender != i_owner) {
            revert FundMe__NotOwner();
        }
        _;
    }

    receive() external payable {
        fund();
    } // send without data

    fallback() external payable {
        fund();
    } //send with data

    //Getters//
    function getAddessToAmountFunded(
        address fundingAddress
    ) external view returns (uint256) {
        return s_addressToAmountFunded[fundingAddress];
    }

    function getFunder(uint256 index) external view returns (address) {
        return s_funders[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }
}
