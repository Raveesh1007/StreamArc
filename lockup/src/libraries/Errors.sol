// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { Lockup } from "../types/Lockup.sol";

/// @title Errors
/// @notice Library containing all custom errors the protocol may revert with.
library Errors {
    /*//////////////////////////////////////////////////////////////////////////
                                STREAMARC-BATCH-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    error StreamArcBatchLockup_BatchSizeZero();

    /*//////////////////////////////////////////////////////////////////////////
                               STREAMARC-LOCKUP-HELPERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when trying to create a linear stream with a cliff time not strictly less than the end time.
    error StreamArcLockupHelpers_CliffTimeNotLessThanEndTime(uint40 cliffTime, uint40 endTime);

    /// @notice Thrown when trying to create a stream with a non zero cliff unlock amount when the cliff time is zero.
    error StreamArcLockupHelpers_CliffTimeZeroUnlockAmountNotZero(uint128 cliffUnlockAmount);

    /// @notice Thrown when trying to create a stream with the native token.
    error StreamArcLockupHelpers_CreateNativeToken(address nativeToken);

    /// @notice Thrown when trying to create a dynamic stream with a deposit amount not equal to the sum of the segment
    /// amounts.
    error StreamArcLockupHelpers_DepositAmountNotEqualToSegmentAmountsSum(
        uint128 depositAmount,
        uint128 segmentAmountsSum
    );

    /// @notice Thrown when trying to create a tranched stream with a deposit amount not equal to the sum of the tranche
    /// amounts.
    error StreamArcLockupHelpers_DepositAmountNotEqualToTrancheAmountsSum(
        uint128 depositAmount,
        uint128 trancheAmountsSum
    );

    /// @notice Thrown when trying to create a stream with a zero deposit amount.
    error StreamArcLockupHelpers_DepositAmountZero();

    /// @notice Thrown when trying to create a dynamic stream with end time not equal to the last segment's timestamp.
    error StreamArcLockupHelpers_EndTimeNotEqualToLastSegmentTimestamp(uint40 endTime, uint40 lastSegmentTimestamp);

    /// @notice Thrown when trying to create a tranched stream with end time not equal to the last tranche's timestamp.
    error StreamArcLockupHelpers_EndTimeNotEqualToLastTrancheTimestamp(uint40 endTime, uint40 lastTrancheTimestamp);

    /// @notice Thrown when trying to create a linear stream with granularity greater than the streamable range.
    error StreamArcLockupHelpers_GranularityTooHigh(uint40 granularity, uint40 streamableRange);

    /// @notice Thrown when trying to create a dynamic stream with no segments.
    error StreamArcLockupHelpers_SegmentCountZero();

    /// @notice Thrown when trying to create a dynamic stream with unordered segment timestamps.
    error StreamArcLockupHelpers_SegmentTimestampsNotOrdered(
        uint256 index,
        uint40 previousTimestamp,
        uint40 currentTimestamp
    );

    /// @notice Thrown when trying to create a stream with the sender as the zero address.
    error StreamArcLockupHelpers_SenderZeroAddress();

    /// @notice Thrown when trying to create a stream with a shape string exceeding 32 bytes.
    error StreamArcLockupHelpers_ShapeExceeds32Bytes(uint256 shapeLength);

    /// @notice Thrown when trying to create a linear stream with a start time not strictly less than the cliff time,
    /// when the cliff time does not have a zero value.
    error StreamArcLockupHelpers_StartTimeNotLessThanCliffTime(uint40 startTime, uint40 cliffTime);

    /// @notice Thrown when trying to create a linear stream with a start time not strictly less than the end time.
    error StreamArcLockupHelpers_StartTimeNotLessThanEndTime(uint40 startTime, uint40 endTime);

    /// @notice Thrown when trying to create a dynamic stream with a start time not strictly less than the first
    /// segment timestamp.
    error StreamArcLockupHelpers_StartTimeNotLessThanFirstSegmentTimestamp(
        uint40 startTime,
        uint40 firstSegmentTimestamp
    );

    /// @notice Thrown when trying to create a tranched stream with a start time not strictly less than the first
    /// tranche timestamp.
    error StreamArcLockupHelpers_StartTimeNotLessThanFirstTrancheTimestamp(
        uint40 startTime,
        uint40 firstTrancheTimestamp
    );

    /// @notice Thrown when trying to create a stream with a zero start time.
    error StreamArcLockupHelpers_StartTimeZero();

    /// @notice Thrown when trying to create a tranched stream with no tranches.
    error StreamArcLockupHelpers_TrancheCountZero();

    /// @notice Thrown when trying to create a tranched stream with unordered tranche timestamps.
    error StreamArcLockupHelpers_TrancheTimestampsNotOrdered(
        uint256 index,
        uint40 previousTimestamp,
        uint40 currentTimestamp
    );

    /// @notice Thrown when trying to create a stream with the sum of the unlock amounts greater than the deposit
    /// amount.
    error StreamArcLockupHelpers_UnlockAmountsSumTooHigh(
        uint128 depositAmount,
        uint128 startUnlockAmount,
        uint128 cliffUnlockAmount
    );

    /*//////////////////////////////////////////////////////////////////////////
                                    STREAMARC-LOCKUP
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when trying to allow to hook a contract that doesn't implement the interface correctly.
    error StreamArcLockup_AllowToHookUnsupportedInterface(address recipient);

    /// @notice Thrown when trying to allow to hook an address with no code.
    error StreamArcLockup_AllowToHookZeroCodeSize(address recipient);

    /// @notice Thrown when the fee transfer fails.
    error StreamArcLockup_FeeTransferFailed(address comptroller, uint256 feeAmount);

    /// @notice Thrown when trying to withdraw with a fee amount less than the minimum fee.
    error StreamArcLockup_InsufficientFeePayment(uint256 feePaid, uint256 minFeeWei);

    /// @notice Thrown when the hook does not return the correct selector.
    error StreamArcLockup_InvalidHookSelector(address recipient);

    /// @notice Thrown when trying to set the native token address when it is already set.
    error StreamArcLockup_NativeTokenAlreadySet(address nativeToken);

    /// @notice Thrown when trying to transfer Stream NFT when transferability is disabled.
    error StreamArcLockup_NotTransferable(uint256 tokenId);

    /// @notice Thrown when trying to withdraw an amount greater than the withdrawable amount.
    error StreamArcLockup_Overdraw(uint256 streamId, uint128 amount, uint128 withdrawableAmount);

    /// @notice Thrown when trying to withdraw a partial amount from a LPG stream.
    error StreamArcLockup_WithdrawAmountNotEqualWithdrawableAmount(
        uint256 streamId,
        uint128 amount,
        uint128 withdrawableAmount
    );

    /// @notice Thrown when trying to cancel or renounce a canceled stream.
    error StreamArcLockup_StreamCanceled(uint256 streamId);

    /// @notice Thrown when trying to cancel, renounce, or withdraw from a depleted stream.
    error StreamArcLockup_StreamDepleted(uint256 streamId);

    /// @notice Thrown when trying to cancel or renounce a stream that is not cancelable.
    error StreamArcLockup_StreamNotCancelable(uint256 streamId);

    /// @notice Thrown when trying to burn a stream that is not depleted.
    error StreamArcLockup_StreamNotDepleted(uint256 streamId);

    /// @notice Thrown when trying to cancel or renounce a settled stream.
    error StreamArcLockup_StreamSettled(uint256 streamId);

    /// @notice Thrown when trying to create a price-gated stream with a target price not greater than the current
    /// oracle price.
    error StreamArcLockup_TargetPriceTooLow(uint128 targetPrice, uint128 latestPrice);

    /// @notice Thrown when `msg.sender` lacks authorization to perform an action.
    error StreamArcLockup_Unauthorized(uint256 streamId, address caller);

    /// @notice Thrown when trying to withdraw to an address other than the recipient's.
    error StreamArcLockup_WithdrawalAddressNotRecipient(uint256 streamId, address caller, address to);

    /// @notice Thrown when trying to withdraw zero tokens from a stream.
    error StreamArcLockup_WithdrawAmountZero(uint256 streamId);

    /// @notice Thrown when trying to withdraw from multiple streams and the number of stream IDs does
    /// not match the number of withdraw amounts.
    error StreamArcLockup_WithdrawArrayCountsNotEqual(uint256 streamIdsCount, uint256 amountsCount);

    /// @notice Thrown when trying to withdraw to the zero address.
    error StreamArcLockup_WithdrawToZeroAddress(uint256 streamId);

    /*//////////////////////////////////////////////////////////////////////////
                                STREAMARC-LOCKUP-STATE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when a function is called on a stream that does not use the expected Lockup model.
    error StreamArcLockupState_NotExpectedModel(Lockup.Model actualLockupModel, Lockup.Model expectedLockupModel);

    /// @notice Thrown when the ID references a null stream.
    error StreamArcLockupState_Null(uint256 streamId);
}
