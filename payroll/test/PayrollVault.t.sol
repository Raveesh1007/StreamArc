// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.29;

import { Test } from "forge-std/Test.sol";
import { PayrollVault, IERC20 } from "../src/PayrollVault.sol";

contract MockUSDC {
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    function decimals() external pure returns (uint8) {
        return 6;
    }

    function mint(address to, uint256 amount) external {
        balanceOf[to] += amount;
    }

    function approve(address spender, uint256 amount) external returns (bool) {
        allowance[msg.sender][spender] = amount;
        return true;
    }

    function transfer(address to, uint256 amount) external returns (bool) {
        balanceOf[msg.sender] -= amount;
        balanceOf[to] += amount;
        return true;
    }

    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        allowance[from][msg.sender] -= amount;
        balanceOf[from] -= amount;
        balanceOf[to] += amount;
        return true;
    }
}

contract PayrollVaultTest is Test {
    PayrollVault vault;
    MockUSDC usdc;

    address boss = makeAddr("boss");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    address stranger = makeAddr("stranger");

    uint256 constant USDC = 1e6;
    uint256 constant MONTH = 30 days;
    uint256 constant WEEK = 7 days;
    uint256 SALARY; // $3,000 / month rate

    function setUp() public {
        vm.warp(1_000_000);
        usdc = new MockUSDC();
        vault = new PayrollVault(IERC20(address(usdc)));
        SALARY = vault.monthlyToRate(3000 * USDC);
        usdc.mint(boss, 1_000_000 * USDC);
        vm.prank(boss);
        usdc.approve(address(vault), type(uint256).max);
    }

    /*//////////////////////////////////////////////////////////////
                                HELPERS
    //////////////////////////////////////////////////////////////*/

    function _deposit(uint256 amount) internal {
        vm.prank(boss);
        vault.deposit(amount);
    }

    function _hire(address who, uint256 rate, uint256 period) internal returns (uint256 streamId) {
        vm.prank(boss);
        uint256 offerId = vault.propose(who, rate, period, 0);
        vm.prank(who);
        streamId = vault.acceptOffer(offerId);
    }

    function _withdrawAll(uint256 id, address who) internal returns (uint256 got) {
        uint256 before = usdc.balanceOf(who);
        vm.prank(who);
        vault.withdraw(id, type(uint256).max, who);
        got = usdc.balanceOf(who) - before;
    }

    /*//////////////////////////////////////////////////////////////
                              POOL / OFFERS
    //////////////////////////////////////////////////////////////*/

    function test_MonthlyToRate() public view {
        assertEq(vault.monthlyToRate(3_000_000_000), uint256(3_000_000_000) * 1e18 / MONTH);
        assertEq(SALARY, 1_157_407_407_407_407_407_407);
    }

    function test_Deposit_And_WithdrawExcess() public {
        _deposit(10_000 * USDC);
        (uint256 bal,,,) = vault.employers(boss);
        assertEq(bal, 10_000 * USDC);
        assertEq(vault.freeBalance(boss), 10_000 * USDC);

        vm.prank(boss);
        vault.withdrawExcess(4000 * USDC, boss);
        assertEq(vault.freeBalance(boss), 6000 * USDC);
    }

    function test_Offer_PayStartsOnAccept() public {
        _deposit(10_000 * USDC);
        vm.prank(boss);
        uint256 offerId = vault.propose(alice, SALARY, 0, 0);

        skip(10 days); // no pay while the offer is open
        vm.prank(alice);
        uint256 id = vault.acceptOffer(offerId);
        assertEq(vault.earned(id), 0);

        skip(MONTH);
        assertApproxEqAbs(vault.earned(id), 3000 * USDC, 1);
        (,,,,, PayrollVault.OfferStatus st, uint256 sid) = vault.offers(offerId);
        assertEq(uint8(st), uint8(PayrollVault.OfferStatus.Accepted));
        assertEq(sid, id);
    }

    function test_Offer_RejectRevokeExpire() public {
        vm.startPrank(boss);
        uint256 o1 = vault.propose(alice, SALARY, 0, 0);
        uint256 o2 = vault.propose(alice, SALARY, 0, 0);
        uint256 o3 = vault.propose(alice, SALARY, 0, block.timestamp + 1 days);
        vault.revokeOffer(o2);
        vm.stopPrank();

        vm.startPrank(alice);
        vault.rejectOffer(o1);
        vm.expectRevert(PayrollVault.InvalidStatus.selector);
        vault.acceptOffer(o1);
        vm.expectRevert(PayrollVault.InvalidStatus.selector);
        vault.acceptOffer(o2);
        skip(2 days);
        vm.expectRevert(PayrollVault.OfferExpired.selector);
        vault.acceptOffer(o3);
        vm.stopPrank();
    }

    function test_Offer_OnlyEmployeeAccepts() public {
        vm.prank(boss);
        uint256 o = vault.propose(alice, SALARY, 0, 0);
        vm.prank(stranger);
        vm.expectRevert(PayrollVault.NotEmployee.selector);
        vault.acceptOffer(o);
    }

    function test_Propose_Validation() public {
        vm.startPrank(boss);
        vm.expectRevert(PayrollVault.InvalidAddress.selector);
        vault.propose(address(0), SALARY, 0, 0);
        vm.expectRevert(PayrollVault.InvalidRate.selector);
        vault.propose(alice, 0, 0, 0);
        vm.expectRevert(PayrollVault.InvalidPeriod.selector);
        vault.propose(alice, SALARY, 366 days, 0);
        vm.expectRevert(PayrollVault.InvalidExpiry.selector);
        vault.propose(alice, SALARY, 0, block.timestamp);
        vm.stopPrank();
    }

    function test_BatchPropose_And_Lists() public {
        address[] memory who = new address[](2);
        uint256[] memory rates = new uint256[](2);
        uint256[] memory periods = new uint256[](2);
        uint256[] memory exp = new uint256[](2);
        (who[0], who[1]) = (alice, bob);
        (rates[0], rates[1]) = (SALARY, SALARY * 2);
        (periods[0], periods[1]) = (0, MONTH);

        vm.prank(boss);
        uint256[] memory ids = vault.batchPropose(who, rates, periods, exp);
        assertEq(ids.length, 2);
        assertEq(vault.offersOfEmployer(boss).length, 2);
        assertEq(vault.offersOfEmployee(bob)[0], ids[1]);

        vm.prank(bob);
        uint256 sid = vault.acceptOffer(ids[1]);
        assertEq(vault.streamsOfEmployer(boss)[0], sid);
        assertEq(vault.streamsOfEmployee(bob)[0], sid);

        uint256[] memory short = new uint256[](1);
        vm.prank(boss);
        vm.expectRevert(PayrollVault.LengthMismatch.selector);
        vault.batchPropose(who, short, periods, exp);
    }

    /*//////////////////////////////////////////////////////////////
                                PAY MODES
    //////////////////////////////////////////////////////////////*/

    function test_Continuous_WithdrawAnytime() public {
        _deposit(10_000 * USDC);
        uint256 id = _hire(alice, SALARY, 0);
        skip(1 days);
        assertEq(vault.withdrawable(id), 100 * USDC - 1); // floor of 3000/30 per day

        uint256 got = _withdrawAll(id, alice);
        assertEq(got, 100 * USDC - 1);
        assertEq(vault.withdrawable(id), 0);
    }

    function test_Withdraw_ToOtherAddress_PartialAmount() public {
        _deposit(10_000 * USDC);
        uint256 id = _hire(alice, SALARY, 0);
        skip(10 days);
        vm.prank(alice);
        vault.withdraw(id, 500 * USDC, bob);
        assertEq(usdc.balanceOf(bob), 500 * USDC);

        vm.prank(alice);
        vm.expectRevert(PayrollVault.InvalidAmount.selector);
        vault.withdraw(id, 600 * USDC, bob);

        vm.prank(stranger);
        vm.expectRevert(PayrollVault.NotEmployee.selector);
        vault.withdraw(id, 1, stranger);
    }

    function test_Payday_LocksUntilPayday() public {
        _deposit(10_000 * USDC);
        uint256 id = _hire(alice, SALARY, MONTH);
        uint256 start = block.timestamp;
        assertEq(vault.nextPayday(id), start + MONTH);

        skip(MONTH - 1);
        assertGt(vault.earned(id), 2999 * USDC);
        assertEq(vault.withdrawable(id), 0);

        skip(1);
        assertApproxEqAbs(vault.withdrawable(id), 3000 * USDC, 1);
        assertEq(vault.nextPayday(id), start + 2 * MONTH);
    }

    function test_Payday_MissedPaydaysAccumulate_Weekly() public {
        _deposit(10_000 * USDC);
        uint256 id = _hire(alice, SALARY, WEEK);
        skip(3 * WEEK + 2 days);
        uint256 first = SALARY * 3 * WEEK / 1e18;
        assertEq(vault.withdrawable(id), first);
        assertEq(_withdrawAll(id, alice), first);

        skip(5 days); // lands exactly on the 4th payday
        assertEq(vault.withdrawable(id), SALARY * 4 * WEEK / 1e18 - first);
    }

    /*//////////////////////////////////////////////////////////////
                              CHANGING TERMS
    //////////////////////////////////////////////////////////////*/

    function test_Raise_AppliesInstantly() public {
        _deposit(10_000 * USDC);
        uint256 id = _hire(alice, SALARY, 0);
        skip(10 days);
        vm.prank(boss);
        vault.raise(id, SALARY * 2);
        skip(10 days);
        assertApproxEqAbs(vault.earned(id), 3000 * USDC, 2); // 1000 + 2000
        (,, uint256 totalRate,) = vault.employers(boss);
        assertEq(totalRate, SALARY * 2);

        vm.prank(boss);
        vm.expectRevert(PayrollVault.NotARaise.selector);
        vault.raise(id, SALARY);
    }

    function test_PayCut_OnlyAfterAccept() public {
        _deposit(10_000 * USDC);
        uint256 id = _hire(alice, SALARY, 0);
        vm.prank(boss);
        vault.proposeChange(id, SALARY / 2, 0);

        skip(10 days); // old rate still runs
        assertApproxEqAbs(vault.earned(id), 1000 * USDC, 1);

        vm.prank(alice);
        vault.acceptChange(id);
        skip(10 days);
        assertApproxEqAbs(vault.earned(id), 1500 * USDC, 2);
    }

    function test_RejectChange_KeepsOldTerms() public {
        _deposit(10_000 * USDC);
        uint256 id = _hire(alice, SALARY, 0);
        vm.prank(boss);
        vault.proposeChange(id, SALARY / 2, MONTH);
        vm.prank(alice);
        vault.rejectChange(id);
        (,,,,, uint256 period,,,,) = vault.streams(id);
        assertEq(period, 0);
        vm.prank(alice);
        vm.expectRevert(PayrollVault.NoPendingChange.selector);
        vault.acceptChange(id);
    }

    function test_ModeSwitch_UnlocksEarned_NewPayFollowsNewMode() public {
        _deposit(10_000 * USDC);
        uint256 id = _hire(alice, SALARY, MONTH);
        skip(10 days);
        assertEq(vault.withdrawable(id), 0);

        vm.prank(boss);
        vault.proposeChange(id, SALARY, WEEK);
        vm.prank(alice);
        vault.acceptChange(id);

        uint256 earnedSoFar = vault.earned(id);
        assertEq(vault.withdrawable(id), earnedSoFar); // all earned unlocked
        skip(WEEK - 1);
        assertEq(vault.withdrawable(id), earnedSoFar); // new pay locked until the new weekly payday
        skip(1);
        assertEq(vault.withdrawable(id), vault.earned(id));
    }

    /*//////////////////////////////////////////////////////////////
                           PAUSE / CANCEL / SAFETY
    //////////////////////////////////////////////////////////////*/

    function test_PauseResume() public {
        _deposit(10_000 * USDC);
        uint256 id = _hire(alice, SALARY, 0);
        skip(10 days);
        vm.prank(boss);
        vault.pause(id);
        uint256 frozen = vault.earned(id);
        skip(20 days);
        assertEq(vault.earned(id), frozen);
        assertEq(vault.runway(boss), type(uint256).max);

        vm.prank(boss);
        vault.resume(id);
        skip(10 days);
        assertApproxEqAbs(vault.earned(id), 2000 * USDC, 2);
    }

    function test_Cancel_PaysPartialPeriodProRata() public {
        _deposit(10_000 * USDC);
        uint256 id = _hire(alice, SALARY, MONTH);
        skip(15 days);
        assertEq(vault.withdrawable(id), 0);

        vm.prank(boss);
        vault.cancel(id);
        assertApproxEqAbs(vault.withdrawable(id), 1500 * USDC, 1);
        skip(30 days);
        assertApproxEqAbs(vault.earned(id), 1500 * USDC, 1); // stopped accruing
        assertApproxEqAbs(_withdrawAll(id, alice), 1500 * USDC, 1);

        vm.prank(boss);
        vm.expectRevert(PayrollVault.InvalidStatus.selector);
        vault.resume(id);
    }

    function test_Employer_CannotTakeEarnedMoney_EvenLocked() public {
        _deposit(5000 * USDC);
        _hire(alice, SALARY, MONTH);
        skip(20 days); // 2000 earned, all locked until payday

        assertApproxEqAbs(vault.freeBalance(boss), 3000 * USDC, 1);
        vm.prank(boss);
        vm.expectRevert(PayrollVault.InsufficientFreeBalance.selector);
        vault.withdrawExcess(3001 * USDC, boss);
        vm.prank(boss);
        vault.withdrawExcess(2999 * USDC, boss);
    }

    function test_PoolRunsDry_DebtStaysOwed_TopUpPays() public {
        _deposit(1000 * USDC);
        uint256 id = _hire(alice, SALARY, 0);
        skip(20 days); // 2000 earned, pool has 1000
        assertEq(vault.runway(boss), 0);
        assertEq(vault.freeBalance(boss), 0);

        assertEq(_withdrawAll(id, alice), 1000 * USDC);
        assertApproxEqAbs(vault.totalOwed(boss), 1000 * USDC, 1);

        vm.prank(alice);
        vm.expectRevert(PayrollVault.InvalidAmount.selector);
        vault.withdraw(id, type(uint256).max, alice);

        _deposit(5000 * USDC);
        assertApproxEqAbs(_withdrawAll(id, alice), 1000 * USDC, 1);
    }

    function test_Runway() public {
        assertEq(vault.runway(boss), type(uint256).max);
        _deposit(6000 * USDC);
        _hire(alice, SALARY, 0);
        _hire(bob, SALARY, 0);
        assertApproxEqAbs(vault.runway(boss), MONTH, 1); // 6000 / (2 * 3000 per month)
        skip(10 days);
        assertApproxEqAbs(vault.runway(boss), 20 days, 1);
    }

    function test_OnlyEmployerManagesStream() public {
        uint256 id = _hire(alice, SALARY, 0);
        vm.startPrank(stranger);
        vm.expectRevert(PayrollVault.NotEmployer.selector);
        vault.pause(id);
        vm.expectRevert(PayrollVault.NotEmployer.selector);
        vault.cancel(id);
        vm.expectRevert(PayrollVault.NotEmployer.selector);
        vault.raise(id, SALARY * 2);
        vm.expectRevert(PayrollVault.NotEmployer.selector);
        vault.proposeChange(id, SALARY / 2, 0);
        vm.stopPrank();
    }

    /*//////////////////////////////////////////////////////////////
                                  FUZZ
    //////////////////////////////////////////////////////////////*/

    /// Random time jumps, raises, pauses, deposits, withdrawals: pool balance matches tokens held, owed + paid = earned.
    function testFuzz_Accounting(uint256 seed, uint256 deposit, uint256 monthlyA, uint256 monthlyB) public {
        deposit = bound(deposit, 1 * USDC, 500_000 * USDC);
        uint256 rA = vault.monthlyToRate(bound(monthlyA, 1 * USDC, 50_000 * USDC));
        uint256 rB = vault.monthlyToRate(bound(monthlyB, 1 * USDC, 50_000 * USDC));
        _deposit(deposit);
        uint256 a = _hire(alice, rA, 0);
        uint256 b = _hire(bob, rB, WEEK);
        uint256 paid;

        for (uint256 i; i < 12; ++i) {
            uint256 r = uint256(keccak256(abi.encode(seed, i)));
            skip(r % 20 days);
            uint256 op = (r >> 64) % 5;
            if (op == 0 && vault.withdrawable(a) > 0) paid += _withdrawAll(a, alice);
            else if (op == 1 && vault.withdrawable(b) > 0) paid += _withdrawAll(b, bob);
            else if (op == 2) {
                (,,,,,, PayrollVault.Status st,,,) = vault.streams(a);
                vm.prank(boss);
                if (st == PayrollVault.Status.Active) vault.pause(a);
                else vault.resume(a);
            } else if (op == 3) {
                (,, uint256 rate,,,,,,,) = vault.streams(b);
                vm.prank(boss);
                vault.raise(b, rate + 1e15);
            } else {
                _deposit((r >> 128) % (1000 * USDC) + 1);
            }

            (uint256 bal,,,) = vault.employers(boss);
            assertEq(usdc.balanceOf(address(vault)), bal);
            uint256 owed = vault.totalOwed(boss);
            uint256 earnedSum = vault.earned(a) + vault.earned(b);
            assertApproxEqAbs(owed + paid, earnedSum, 2);
            assertLe(paid, earnedSum);
        }
    }
}
