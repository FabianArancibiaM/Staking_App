// SPDX-License-Identifier: MIT
pragma solidity 0.8.37;

import "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";


contract StakingApp is Ownable {

   address public stakingToken;
   uint256 public stakingPeriod;
   uint256 public fixStakingAmount;
   uint256 public rewardPerPeriod;

   mapping(address => uint256) public userBalance;
   mapping(address => uint256) public depositTime;

   event StakingPeriodChanged(uint256 newStakingPeriod);
   event DepositToken(address userAddress, uint256 depositAmount);
   event WithdrawToken(address userAddress, uint256 withdrawAmount);
   event EtherSent(uint256 amount);

   constructor(address stakingToken_, address owner_, uint256 stakingPeriod_, uint256 fixStakingAmount_, uint256 rewardPerPeriod_) Ownable(owner_) {
      stakingToken = stakingToken_;
      stakingPeriod = stakingPeriod_;
      fixStakingAmount = fixStakingAmount_;
      rewardPerPeriod = rewardPerPeriod_;
   }

   // Deposit
   function depositToken(uint256 tokenAmountToDeposit_) external {
      require(tokenAmountToDeposit_ == fixStakingAmount, "Incorrect amount to deposit");
      require(userBalance[msg.sender] == 0, "User already has a deposit");
      IERC20(stakingToken).transferFrom(msg.sender, address(this), tokenAmountToDeposit_);
      userBalance[msg.sender] += tokenAmountToDeposit_;
      depositTime[msg.sender] = block.timestamp;
      emit DepositToken(msg.sender, tokenAmountToDeposit_);
   }

   // withdraw

   function withdrawToken() external {
      uint256 userBalance_ = userBalance[msg.sender];
      userBalance[msg.sender] = 0;
      IERC20(stakingToken).transfer(msg.sender, userBalance_);

      emit WithdrawToken(msg.sender, userBalance_);
   }

   // Reward

   function cleanReward() external {
      require(userBalance[msg.sender] == fixStakingAmount, "No staking");
      uint256 periods = block.timestamp - depositTime[msg.sender];
      require(periods >= stakingPeriod, "Staking period not completed"); 
      depositTime[msg.sender] = block.timestamp;
      (bool success, ) = msg.sender.call{value: rewardPerPeriod}("");
      require(success, "Failed to transfer reward");

   }

   function feedContract() external payable onlyOwner {}

   receive() external payable onlyOwner {
      emit EtherSent(msg.value);
   }

   function changeStakingPeriod(uint256 newStakingPeriod) external onlyOwner {
      stakingPeriod = newStakingPeriod;
      emit StakingPeriodChanged(newStakingPeriod);
   }  


}