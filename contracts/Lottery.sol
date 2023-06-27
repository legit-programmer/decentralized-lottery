//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Lottery {
    address[] public players;
    uint256 public usdEntryFee;
    AggregatorV3Interface priceFeed;
    constructor(address _priceFeed) {
        usdEntryFee=50 * (10**18);
        priceFeed = AggregatorV3Interface(_priceFeed);
    }
    function enter() public payable {
        
        players.push(msg.sender);
    }

    function getEntranceFee() public view returns(uint256){
        (,int256 price,,,) = priceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(price)* (10**10);// 18 dec. 
    }

    function startLottery() public {

    }

    function endLottery() public {

    }
}