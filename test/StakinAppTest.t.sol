// SPDX-License-Identifier: MIT
pragma solidity 0.8.37;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "../src/StakingApp.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";


contract StakinAppTest is Test {

    StakingApp public stakingApp;
    StakingToken public stakingToken;


    string public name_ = "Staking Token";
    string public symbol_= "STK";

    address public owner_ = vm.addr(1);
    address public randomUser_ = vm.addr(2);
    uint256 public stakingPeriod_ = 100000000;
    uint256 public fixStakingAmount_ = 10;
    uint256 public rewardPerPeriod_ = 1 ether;


    function setUp() external {
        // Setup code for the test environment
        stakingToken = new StakingToken(name_, symbol_);
        stakingApp = new StakingApp(address(stakingToken), owner_, stakingPeriod_, fixStakingAmount_, rewardPerPeriod_);
    }

    function testStakingTokenCorrectCorrectlyDeployed() external view{
        assert(address(stakingToken) != address(0));
    }
    function testStakingAppCorrectCorrectlyDeployed() external view{
        assert(address(stakingApp) != address(0));
    }

    function testChangeStakingPeriodIsOwner() external {
        vm.startPrank(owner_);
        uint256 stakingPeriodDef_ = 2;
        uint256 oldStakingPeriod_ = stakingApp.stakingPeriod();
        stakingApp.changeStakingPeriod(stakingPeriodDef_);
        uint256 newStakingPeriod_ = stakingApp.stakingPeriod();
        assert(oldStakingPeriod_ != newStakingPeriod_);
        vm.stopPrank();
    }   

    function testChangeStakingPeriodNotOwner() external {
        uint256 newStakingPeriod = 2;
        vm.expectRevert();
        stakingApp.changeStakingPeriod(newStakingPeriod);
    }   

    function testContractReceivesEther() external {
        vm.startPrank(owner_);
        uint256 amount_ = 1 ether;
        vm.deal(owner_, amount_);
        uint256 initialBalance = address(stakingApp).balance;
        (bool success, ) = address(stakingApp).call{value: amount_}("");
        require(success, "Failed to send Ether");
        uint256 finalBalance = address(stakingApp).balance;
        assertEq(finalBalance, initialBalance + amount_);
        vm.stopPrank();
    }   

    // Test Deposit Token
    function testDepositTokenStakingAmountNotCorrect() external {
        vm.startPrank(randomUser_);
        uint256 incorrectAmount = 5;
        vm.expectRevert("Incorrect amount to deposit");
        stakingApp.depositToken(incorrectAmount);
        vm.stopPrank();
    }

    function testDepositTokenCorrectly() external {
        vm.startPrank(randomUser_);
        uint256 tokenAmount = stakingApp.fixStakingAmount();
        stakingToken.mint(tokenAmount);
        uint256 userBalanceBefore = stakingToken.balanceOf(randomUser_);
        uint256 elapsedTimeBefore = stakingApp.depositTime(randomUser_);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositToken(tokenAmount);
        uint256 userBalanceAfter = stakingToken.balanceOf(randomUser_);
        uint256 elapsedTimeAfter = stakingApp.depositTime(randomUser_);
        assert(elapsedTimeBefore== 0);
        assertEq(elapsedTimeAfter, block.timestamp);
        assertEq(userBalanceAfter, userBalanceBefore - tokenAmount);
        vm.stopPrank();
    }

    function testDepositTokenNotCorrectly() external {
        vm.startPrank(randomUser_);
        uint256 tokenAmount = stakingApp.fixStakingAmount();
        stakingToken.mint(tokenAmount);
        uint256 userBalanceBefore = stakingToken.balanceOf(randomUser_);
        uint256 elapsedTimeBefore = stakingApp.depositTime(randomUser_);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        stakingApp.depositToken(tokenAmount);
        uint256 userBalanceAfter = stakingToken.balanceOf(randomUser_);
        uint256 elapsedTimeAfter = stakingApp.depositTime(randomUser_);
        assert(elapsedTimeBefore== 0);
        assertEq(elapsedTimeAfter, block.timestamp);
        assertEq(userBalanceAfter, userBalanceBefore - tokenAmount);

        stakingToken.mint(tokenAmount);
        IERC20(stakingToken).approve(address(stakingApp), tokenAmount);
        vm.expectRevert("User already has a deposit");
        stakingApp.depositToken(tokenAmount);

        vm.stopPrank();
    }
}