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

contract DSCEngine {

  error DSCEngine__MustBeMoreThanZero();

  modifier moreThanZero(uint256 _amount) {
    if(_amount <= 0) {
      revert DSCEngine__MustBeMoreThanZero();
    }
    _;
  }

  function depositCollateralAndMintDSC() external {
    // Deposit Collateral
    // Mint DSC Tokens
  }

  /*
  * @notice Deposit Collateral
  */
  function depositCollateral(address _tokenCollateralAddress, uint256 _amount) external moreThanZero(_amount) {
    // Deposit Collateral
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