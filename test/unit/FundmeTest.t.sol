// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Test , console} from "forge-std/Test.sol";
import {FundMe} from "../../src/Fundme.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundmeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; //100_000_000_000_000_000 wei
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        // us--> fundMe contract --> Fundme
        // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // deal is a cheatcode which gives USER some ETH.
    }

    function testMinimundollarisfive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // Next line should revert/fails.
        fundMe.fund();
    }

    modifier funded() {
        vm.prank(USER); // Next tx will be sent by USER.
        // prank is a cheatcode that creates a fake new address.
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testFundUpdatesFundedDataStructure() public funded {
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFundertoarrayofFunders() public funded {
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithdrawWithSingleFunder() public funded {
        // arrange
        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // act
        uint256 gasStart = gasleft(); // Tells how much gas is remaining.
        vm.txGasPrice(GAS_PRICE); // Sets the gas price for the next transaction.
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 gasEnd = gasleft();
        uint256 gasUsed = (gasStart - gasEnd) * GAS_PRICE;
        console.log("Gas used:", gasUsed);

        // assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFrommultipleFunderscheaper() public funded {
        // arrange
        uint160 numberOfFunders = 10; // if we want to use numbers to generate addresses we have to use uint160.
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank(address(i)); // Next tx will be sent by address(i).
            // fundMe.fund{value: SEND_VALUE}();

            // Shortcut of above 2 lines--
            hoax(address(i), SEND_VALUE); // hoax is combination of prank and deal cheatcodes.
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // act
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.cheaperWithdraw();

        // assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawFrommultipleFunders() public funded {
        // arrange
        uint160 numberOfFunders = 10; // if we want to use numbers to generate addresses we have to use uint160.
        uint160 startingFunderIndex = 1;

        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank(address(i)); // Next tx will be sent by address(i).
            // fundMe.fund{value: SEND_VALUE}();

            // Shortcut of above 2 lines--
            hoax(address(i), SEND_VALUE); // hoax is combination of prank and deal cheatcodes.
            fundMe.fund{value: SEND_VALUE}();
        }

        uint256 startingFundMeBalance = address(fundMe).balance;
        uint256 startingOwnerBalance = fundMe.getOwner().balance;

        // act
        vm.txGasPrice(GAS_PRICE);
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // assert
        uint256 endingFundMeBalance = address(fundMe).balance;
        uint256 endingOwnerBalance = fundMe.getOwner().balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    // Types of tests--

    // 1. Unit tests --> Testing a single unit(A specific function in isolation)

    // 2. Integration tests --> Testing multiple units together

    // 3. Forked tests --> Testing on mainnet fork(Simulated real environment)

    // 4. Staging tests --> Testing on a testnet(like sepolia)
}
 