//SPDX-License-Identifier: MIT

// Layout of Contract:
// version
// imports
// interfaces, libraries, contracts
// errors
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

pragma solidity ^0.8.18;

import { DecentralizedStableCoin } from "./DecentralizedStableCoin.sol";
import { ReentrancyGuard } from '@openzeppelin/contracts/utils/ReentrancyGuard.sol';
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


/**
 * @title DSCEngine
 * @author Franco Perez
 * 
 * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token = 1 USD value peg.
 * This stablecoin has the properties:
 * - Exogenous Collateral
 * - Dollar Pegged
 * - Algorithmically stable
 * 
 * - It is similar to DAI if DAI had no governance, no fees, and was only back by wETH and wBTC.
 * 
 * @notice This contract is the core of the DSC System. It handles all the logic for mining and redeeming DSC, as well as
 the depositing & withdrawing collateral.
 * @notice This contract is very loosely based on the MakerDAO DSS (DAI) system.
 */

contract DSCEngine is ReentrancyGuard{

  error DSCEngine__MustBeMoreThanZero();
  error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeTheSameLength();
  error DSCEngine__TokenNotAllowed();
  error DSCEngine__HealthFactorBroken(uint256 healthFactorValue);
  error DSCEngine__TranferFailed();
  error DSCEngine__MintFailed();

  uint256 private constant LIQUIDATION_THRESHOLD = 50;
  uint256 private constant LIQUIDATION_PRECISION = 100;
  uint256 private constant MIN_HEALTH_FACTOR = 1 ether;
  uint256 private constant PRECISION = 1e18;
  uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;

  mapping(address token => address priceFeed) private s_priceFeeds;
  mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;
  mapping(address user => uint256 amountDscMinted) private s_DSCMinted;

  address[] private s_collateralTokens;

  DecentralizedStableCoin private i_dsc;

  event CollateralDeposited(address indexed user, address indexed token, uint256 amount);
  event DSCEngine__DSCMinted();

  modifier moreThanZero(uint256 _amount) {
    if(_amount <= 0) {
      revert DSCEngine__MustBeMoreThanZero();
    }
    _;
  }

  modifier allowedToken(address token){
    if(s_priceFeeds[token] == address(0)){
      revert DSCEngine__TokenNotAllowed();
    }
    _;
  }

  constructor(
    address[] memory tokenAddreses,
    address[] memory priceFeedAddresses,
    address dscAddress
  ){
    if(tokenAddreses.length != priceFeedAddresses.length){
      revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeTheSameLength();
    }
    for(uint256 i = 0; i < tokenAddreses.length; i++){
      s_priceFeeds[tokenAddreses[i]] = priceFeedAddresses[i];
    }
    i_dsc = DecentralizedStableCoin(dscAddress);
  }

  function _getAccountInformation(address user) private view returns(uint256 totalMinted, uint256 collateralValueInUsd) {
    totalMinted = s_DSCMinted[user];
    collateralValueInUsd = getAccountCollateralValue(user);
  }

  function _healthFactor(address user) internal view returns(uint256) {
    (uint256 totalMinted, uint256 collateralValueInUsd) = _getAccountInformation(user);
    return _calculateHealthFactor(totalMinted, collateralValueInUsd);
  }

  function revertIfHealthFactorIsBroken(address user) internal view{
    // Health Factor
    uint256 userHealthFactor = _healthFactor(user);
    if(userHealthFactor <= MIN_HEALTH_FACTOR){
      revert DSCEngine__HealthFactorBroken(userHealthFactor);
    }
  }

  function depositCollateralAndMintDSC() external {
    // Deposit Collateral
    // Mint DSC Tokens
  }

  /*
  * @notice Deposit Collateral
  */
  function depositCollateral(address _tokenCollateralAddress, uint256 _amount) external moreThanZero(_amount) allowedToken(_tokenCollateralAddress) nonReentrant{
    s_collateralDeposited[msg.sender][_tokenCollateralAddress] += _amount;
    emit CollateralDeposited(msg.sender, _tokenCollateralAddress, _amount);
    bool success = IERC20(_tokenCollateralAddress).transferFrom(msg.sender, address(this), _amount);
    if(!success){
      revert DSCEngine__TranferFailed();
    }
  }

  function redeemCollateralForDSC() external {
    // Redeem DSC Tokens
  }

  function redeemCollateral() external {
  }
  
  function mintDSC(uint256 amountDscToMint) external moreThanZero(amountDscToMint) nonReentrant {
    s_DSCMinted[msg.sender] += amountDscToMint;
    revertIfHealthFactorIsBroken(msg.sender);
    bool minted = i_dsc.mint(msg.sender, amountDscToMint);
    if(!minted){
      revert DSCEngine__MintFailed();
    }
  }

  function burnDSC() external {
    // Burn DSC Tokens
  }

  function liquidate() external {
    // Liquidate
  }

  function healthFactor() external {
    // Health Factor
  }

  //////////////////////////////////////////
  // Internal & Private View Functions  /////
  //////////////////////////////////////////
  function _getUsdValue(address token, uint256 amount) private view returns(uint256){
    (,int256 price,,,) = AggregatorV3Interface(s_priceFeeds[token]).latestRoundData();
    return ((amount * PRECISION) / (uint256(price) * ADDITIONAL_FEED_PRECISION));
  }

    function _calculateHealthFactor(
        uint256 totalDscMinted,
        uint256 collateralValueInUsd
    ) internal pure returns (uint256)
    {
        if (totalDscMinted == 0) return type(uint256).max;
        uint256 collateralAdjustedForThreshold = (collateralValueInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;
        return (collateralAdjustedForThreshold * PRECISION) / totalDscMinted;
    }

  //////////////////////////////////////////
  // External & Public View Functions  /////
  //////////////////////////////////////////
  function getAccountCollateralValue(address user) public view returns(uint256 totalCollateralValueInUsd){
    for(uint256 i = 0; i < s_collateralTokens.length; i++){
      address token = s_collateralTokens[i];
      uint256 amount = s_collateralDeposited[user][token];
      totalCollateralValueInUsd += _getUsdValue(token, amount);
    }
    return totalCollateralValueInUsd;
  }


}