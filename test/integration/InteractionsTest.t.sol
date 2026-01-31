// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test , console} from "forge-std/Test.sol";
import {FundMe} from "../../src/Fundme.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";
import {FundFundMe, WithdrawFundMe} from "../../script/interactions.s.sol";

contract InteractionsTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; //100_000_000_000_000_000 wei
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp () external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // deal is a cheatcode which gives USER some ETH.
}
    
   /* function testUserCanFundInteractions() public {
        FundFundMe fundFundMe = new FundFundMe();
        fundFundMe.fundFundMe(address(fundMe));

        WithdrawFundMe withdrawFundMe = new WithdrawFundMe();
        withdrawFundMe.withdrawFundMe(address(fundMe));
*/
    function testUserCanFundInteractions() public {
    // Arrange
    vm.prank(USER);
    fundMe.fund{value: SEND_VALUE}();

    // Act
    vm.prank(fundMe.getOwner());
    fundMe.withdraw();

    // Assertfunction testUserCanFundInteractions() public {
    // Arrange
    vm.prank(USER);
    fundMe.fund{value: SEND_VALUE}();

    // Act
    vm.prank(fundMe.getOwner());
    fundMe.withdraw();

    // Assert
        assertEq(address(fundMe).balance, 0);

    }
}