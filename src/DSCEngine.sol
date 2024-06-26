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
  error DSCEngine__TranferFailed();

  mapping(address token => address priceFeed) private s_priceFeeds;
  mapping(address user => mapping(address token => uint256 amount)) private s_collateralDeposited;

  DecentralizedStableCoin private i_dsc;

  event CollateralDeposited(address indexed user, address indexed token, uint256 amount);

  modifier moreThanZero(uint256 _amount) {
    if(_amount <= 0) {
      revert DSCEngine__MustBeMoreThanZero();
    }
    _;
  }

  modifier allowedToken(address token){
    if(s_priceFeeds[token] == address(0)){
      revert DSCEngine__allowedToken();
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

  }

  function depositCollateralAndMintDSC() external {
    // Deposit Collateral
    // Mint DSC Tokens
  }

  /*
  * @notice Deposit Collateral
  */
  function depositCollateral(address _tokenCollateralAddress, uint256 _amount) external moreThanZero(_amount) allowedToken(_tokenCollateralAddress) nonReentrant{
    // Deposit Collateral
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
  
  function mintDSC() external {
    // Mint DSC Tokens
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
}