//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Lottery is Ownable {
    address[] public players;
    uint256 public usdEntryFee;
    AggregatorV3Interface priceFeed;
    enum LotteryState{
        OPEN,
        CLOSED,
        CALCULATE_WINNER
    }

    LotteryState public state;

    constructor(address _priceFeed) {
        usdEntryFee=50 * (10**18);
        priceFeed = AggregatorV3Interface(_priceFeed);
        state = LotteryState.CLOSED;
    }

    function enter() public payable {
        require(state==LotteryState.CLOSED, "Lottery is already opened!");
        require(msg.value >=getEntranceFee(), "Not enough eth!");
        players.push(msg.sender);
    }

    function getEntranceFee() public view returns(uint256){
        (,int256 price,,,) = priceFeed.latestRoundData();
        uint256 adjustedPrice = uint256(price)* (10**10);// 18 dec.
        uint256 costToEnter =  usdEntryFee * (10**18) / adjustedPrice;
        return costToEnter;
    }

    function startLottery() public onlyOwner{
        require(state==LotteryState.CLOSED, "Cant start it yet...");
        state = LotteryState.OPEN;
    }

    function endLottery() public onlyOwner {
        require(state==LotteryState.OPEN, "Lottery already closed...");

    }
}