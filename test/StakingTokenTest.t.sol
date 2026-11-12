// SPDX-License-Identifier: MIT
pragma solidity 0.8.37;

import "forge-std/Test.sol";
import "../src/StakingToken.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract StakingTokenTest is Test {

    StakingToken public stakingToken;
    string public name = "Staking Token";
    string public symbol = "STK";
    address public randomUser = vm.addr(1);

    function setUp() public {
        stakingToken = new StakingToken(name, symbol);
    }

    function testMintCorrectly() public {
        vm.startPrank(randomUser);
        uint256 amount_ = 1 ether;

        // Token balance previusly minted
        uint256 balanceBefore = IERC20(address(stakingToken)).balanceOf(randomUser);
        stakingToken.mint(amount_);
        // Token balance after minted
        uint256 balanceAfter = IERC20(address(stakingToken)).balanceOf(randomUser);

        assert(balanceAfter - balanceBefore == amount_);
        vm.stopPrank();
    }


}