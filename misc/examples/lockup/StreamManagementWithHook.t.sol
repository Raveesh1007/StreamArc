// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { IStreamArcLockup } from "@streamarc/lockup/src/interfaces/IStreamArcLockup.sol";

import { Test } from "forge-std/src/Test.sol";
import { StreamManagementWithHook } from "./StreamManagementWithHook.sol";

contract MockERC20 is ERC20 {
    constructor(address to) ERC20("MockERC20", "MockERC20") {
        _mint(to, 1_000_000e18);
    }
}

contract StreamManagementWithHookTest is Test {
    StreamManagementWithHook internal streamManager;
    IStreamArcLockup internal streamarcLockup;

    ERC20 internal token;
    uint128 internal amount = 10e18;
    uint256 internal defaultStreamId;

    address internal alice;
    address internal bob;
    address internal comptroller;

    function setUp() public {
        vm.createSelectFork("ethereum");

        // Create a test users
        alice = makeAddr("Alice");
        bob = makeAddr("Bob");
        comptroller = 0x0000008ABbFf7a84a2fE09f9A9b74D3BC2072399;

        // Create a mock ERC20 token and send 1M tokens to Bob
        token = new MockERC20(bob);

        // Load StreamArc Lockup
        streamarcLockup = IStreamArcLockup(0x93b37Bd5B6b278373217333Ac30D7E74c85fBDCB);

        // Deploy StreamManagementWithHook contract
        streamManager = new StreamManagementWithHook(streamarcLockup, token);

        // Whitelist the contract to be able to hook into StreamArc Lockup contract
        vm.startPrank(comptroller);
        streamarcLockup.allowToHook(address(streamManager));
        vm.stopPrank();

        // Approve streamManager to spend MockERC20 on behalf of Bob
        vm.startPrank(bob);
        token.approve(address(streamManager), type(uint128).max);
    }

    // Test creating a stream from Bob (Stream Manager Owner) to Alice (Beneficiary)
    function test_Create() public {
        // Create a stream with Alice as the beneficiary
        uint256 streamId = streamManager.create({ beneficiary: alice, depositAmount: amount });

        // Check balances
        assertEq(token.balanceOf(alice), 0);
        assertEq(token.balanceOf(bob), 1_000_000e18 - amount);
        assertEq(token.balanceOf(address(streamManager.STREAMARC())), amount);

        // Check stream details are correct
        assertEq(address(streamarcLockup.getUnderlyingToken(streamId)), address(token));
        assertEq(streamarcLockup.getRecipient(streamId), address(streamManager));
        assertEq(streamarcLockup.getDepositedAmount(streamId), amount);
        assertEq(streamarcLockup.isCancelable(streamId), true);
        assertEq(streamarcLockup.isTransferable(streamId), false);

        // Check streamManager details are correct
        assertEq(streamManager.streamBeneficiaries(streamId), alice);
    }

    modifier givenStreamsCreated() {
        // Create a stream with Alice as the beneficiary
        defaultStreamId = streamManager.create({ beneficiary: alice, depositAmount: amount });
        _;
    }

    // Test that withdraw from StreamArc stream reverts if it is directly called on the StreamArc Lockup contract
    function test_Withdraw_RevertWhen_CallerNotStreamManager() public givenStreamsCreated {
        // Warp time to exceed total duration
        vm.warp({ newTimestamp: block.timestamp + 60 weeks });

        // Prank Alice to be the `msg.sender`.
        vm.startPrank(alice);

        // Since Alice is the `msg.sender`, `withdraw` to StreamArc stream should revert due to hook restriction
        vm.expectRevert(abi.encodeWithSelector(StreamManagementWithHook.CallerNotThisContract.selector));
        streamarcLockup.withdraw(defaultStreamId, address(streamManager), 1e18);
    }

    // Test that withdraw from StreamArc stream succeeds if it is called through the `streamManager` contract
    function test_Withdraw() public givenStreamsCreated {
        // Advance time enough to make cliff period over and the total duration to be over
        vm.warp({ newTimestamp: block.timestamp + 60 weeks });

        // Prank Alice to be the `msg.sender`
        vm.startPrank(alice);

        // Alice can withdraw from the streamManager contract
        streamManager.withdraw(defaultStreamId, 1e18);

        assertEq(token.balanceOf(alice), 1e18);

        // Withdraw max tokens from the stream
        uint256 fee = streamarcLockup.calculateMinFeeWei(defaultStreamId);
        streamManager.withdrawMax{ value: fee }(defaultStreamId);

        assertEq(token.balanceOf(alice), 10e18);
    }
}
