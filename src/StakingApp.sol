// SPDX-License-Identifier: MIT
pragma solidity 0.8.37;

contract StakingApp {
   address public stakingToken;
   address public admin;

   constructor(address stakingToken_) {
      stakingToken = stakingToken_;
      admin = msg.sender;
   }    
}