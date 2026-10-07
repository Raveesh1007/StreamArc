// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { UD21x18 } from "@prb/math/src/UD21x18.sol";

/// @title Errors
/// @notice Library with custom errors used across the Flow contract.
library Errors {
    /*//////////////////////////////////////////////////////////////////////////
                                    STREAMARC-FLOW
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when trying to create a stream with the native token.
    error StreamArcFlow_CreateNativeToken(address nativeToken);

    /// @notice Thrown when trying to create a pending stream with zero rate per second.
    error StreamArcFlow_CreateRatePerSecondZero();

    /// @notice Thrown when trying to create a stream with a zero deposit amount.
    error StreamArcFlow_DepositAmountZero(uint256 streamId);

    /// @notice Thrown when trying to withdraw with a fee amount less than the minimum fee.
    error StreamArcFlow_InsufficientFeePayment(uint256 feePaid, uint256 minFeeWei);

    /// @notice Thrown when an unexpected error occurs during the calculation of an amount.
    error StreamArcFlow_InvalidCalculation(uint256 streamId, uint128 availableAmount, uint128 amount);

    /// @notice Thrown when trying to create a stream with a token with decimals greater than 18.
    error StreamArcFlow_InvalidTokenDecimals(address token);

    /// @notice Thrown when trying to set the native token address when it is already set.
    error StreamArcFlow_NativeTokenAlreadySet(address nativeToken);

    /// @notice Thrown when trying to set zero address as native token.
    error StreamArcFlow_NativeTokenZeroAddress();

    /// @notice Thrown when trying to adjust the rate per second to zero.
    error StreamArcFlow_NewRatePerSecondZero(uint256 streamId);

    /// @notice Thrown when the recipient address does not match the stream's recipient.
    error StreamArcFlow_NotStreamRecipient(address recipient, address streamRecipient);

    /// @notice Thrown when the sender address does not match the stream's sender.
    error StreamArcFlow_NotStreamSender(address sender, address streamSender);

    /// @notice Thrown when trying to transfer Stream NFT when transferability is disabled.
    error StreamArcFlow_NotTransferable(uint256 streamId);

    /// @notice Thrown when trying to withdraw an amount greater than the withdrawable amount.
    error StreamArcFlow_Overdraw(uint256 streamId, uint128 amount, uint128 withdrawableAmount);

    /// @notice Thrown when trying to change the rate per second with the same rate per second.
    error StreamArcFlow_RatePerSecondNotDifferent(uint256 streamId, UD21x18 ratePerSecond);

    /// @notice Thrown when trying to refund zero tokens from a stream.
    error StreamArcFlow_RefundAmountZero(uint256 streamId);

    /// @notice Thrown when trying to refund an amount greater than the refundable amount.
    error StreamArcFlow_RefundOverflow(uint256 streamId, uint128 refundAmount, uint128 refundableAmount);

    /// @notice Thrown when trying to create a stream with the sender as the zero address.
    error StreamArcFlow_SenderZeroAddress();

    /// @notice Thrown when trying to get depletion time of a stream with zero balance.
    error StreamArcFlow_StreamBalanceZero(uint256 streamId);

    /// @notice Thrown when trying to perform a disallowed action on a non-paused stream.
    error StreamArcFlow_StreamNotPaused(uint256 streamId);

    /// @notice Thrown when trying to perform a disallowed action on a pending stream.
    error StreamArcFlow_StreamPending(uint256 streamId, uint40 snapshotTime);

    /// @notice Thrown when `msg.sender` lacks authorization to perform an action.
    error StreamArcFlow_Unauthorized(uint256 streamId, address caller);

    /// @notice Thrown when trying to withdraw to an address other than the recipient's.
    error StreamArcFlow_WithdrawalAddressNotRecipient(uint256 streamId, address caller, address to);

    /// @notice Thrown when trying to withdraw zero tokens from a stream.
    error StreamArcFlow_WithdrawAmountZero(uint256 streamId);

    /// @notice Thrown when trying to withdraw to the zero address.
    error StreamArcFlow_WithdrawToZeroAddress(uint256 streamId);

    /*//////////////////////////////////////////////////////////////////////////
                                 STREAMARC-FLOW-STATE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the ID references a null stream.
    error StreamArcFlowState_Null(uint256 streamId);

    /// @notice Thrown when trying to perform a disallowed action on a paused stream.
    error StreamArcFlowState_StreamPaused(uint256 streamId);

    /// @notice Thrown when trying to perform a disallowed action on a voided stream.
    error StreamArcFlowState_StreamVoided(uint256 streamId);

    /// @notice Thrown when `msg.sender` lacks authorization to perform an action.
    error StreamArcFlowState_Unauthorized(uint256 streamId, address caller);
}
