//SPDX-License-Identifier:MIT
pragma solidity ^0.8.0;
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFV2WrapperConsumerBase.sol";

contract Lottery is VRFV2WrapperConsumerBase, Ownable {
    address[] public players;
    uint256 public usdEntryFee;
    AggregatorV3Interface priceFeed;
    enum LotteryState{
        OPEN,
        CLOSED,
        CALCULATE_WINNER
    }

    LotteryState public state;

    // Address LINK - hardcoded for Sepolia
    address linkAddress = 0x779877A7B0D9E8603169DdbD7836e478b4624789;

    // address WRAPPER - hardcoded for Sepolia
    address wrapperAddress = 0xab18414CD93297B0d12ac29E63Ca20f515b3DB46;
    uint32 callbackGasLimit = 100000;
    uint16 requestConfirmations = 2;
    uint32 numWords = 1;
    uint256[] result;
    uint256 lastRequestId;

    constructor(address _priceFeed) VRFV2WrapperConsumerBase(linkAddress, wrapperAddress) {
        usdEntryFee=50 * (10**18);
        priceFeed = AggregatorV3Interface(_priceFeed);
        state = LotteryState.CLOSED;
    }

    function requestRandomWords()
        external
        onlyOwner
        returns (uint256 requestId)
    {
        requestId = requestRandomness(
            callbackGasLimit,
            requestConfirmations,
            numWords
        );
        lastRequestId = requestId;
        return requestId;
    }

    function fulfillRandomWords(uint256 _requestId, uint256[] memory _randomWords) internal override {
        require(_requestId!=0, "request not yet fulfilled");
        result = _randomWords;

    }
    function getRandomWords() external view returns(uint256[] memory randomWords){
        return result;
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
        state = LotteryState.CALCULATE_WINNER;


    }
}