// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { UD60x18 } from "@prb/math/src/UD60x18.sol";

import { ClaimType } from "../types/MerkleBase.sol";

/// @title Errors
/// @notice Library containing all custom errors the protocol may revert with.
library Errors {
    /*//////////////////////////////////////////////////////////////////////////
                            STREAMARC-FACTORY-MERKLE-BASE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when trying to create a campaign with native token.
    error StreamArcFactoryMerkleBase_ForbidNativeToken(address nativeToken);

    /// @notice Thrown when trying to set the native token address when it is already set.
    error StreamArcFactoryMerkleBase_NativeTokenAlreadySet(address nativeToken);

    /// @notice Thrown when trying to set zero address as native token.
    error StreamArcFactoryMerkleBase_NativeTokenZeroAddress();

    /*//////////////////////////////////////////////////////////////////////////
                          STREAMARC-FACTORY-MERKLE-EXECUTE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when trying to create a merkle execute campaign with a target that is not a contract.
    error StreamArcFactoryMerkleExecute_TargetNotContract(address target);

    /*//////////////////////////////////////////////////////////////////////////
                             STREAMARC-FACTORY-MERKLE-LT
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when trying to create an LT campaign with tranches' unlock percentages not adding up to 100%.
    error StreamArcFactoryMerkleLT_TotalPercentageNotOneHundred(uint64 totalPercentage);

    /*//////////////////////////////////////////////////////////////////////////
                             STREAMARC-FACTORY-MERKLE-VCA
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when trying to create a Merkle VCA campaign with zero aggregate amount.
    error StreamArcFactoryMerkleVCA_AggregateAmountZero();

    /// @notice Thrown if expiration time is zero.
    error StreamArcFactoryMerkleVCA_ExpirationTimeZero();

    /// @notice Thrown if expiration time is within 1 week from the vesting end time.
    error StreamArcFactoryMerkleVCA_ExpirationTooEarly(uint40 vestingEndTime, uint40 expiration);

    /// @notice Thrown if the start time is zero.
    error StreamArcFactoryMerkleVCA_StartTimeZero();

    /// @notice Thrown if the unlock percentage is greater than 100%.
    error StreamArcFactoryMerkleVCA_UnlockPercentageTooHigh(UD60x18 unlockPercentage);

    /// @notice Thrown if vesting end time is not greater than the vesting start time.
    error StreamArcFactoryMerkleVCA_VestingEndTimeNotGreaterThanVestingStartTime(
        uint40 vestingStartTime,
        uint40 vestingEndTime
    );

    /*//////////////////////////////////////////////////////////////////////////
                                STREAMARC-MERKLE-BASE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when caller is not the comptroller.
    error StreamArcMerkleBase_CallerNotComptroller(address comptroller, address caller);

    /// @notice Thrown when trying to claim after the campaign has expired.
    error StreamArcMerkleBase_CampaignExpired(uint256 blockTimestamp, uint40 expiration);

    /// @notice Thrown when trying to claim before the campaign start time.
    error StreamArcMerkleBase_CampaignNotStarted(uint256 blockTimestamp, uint40 campaignStartTime);

    /// @notice Thrown when trying to clawback when the current timestamp is over the grace period and the campaign has
    /// not expired.
    error StreamArcMerkleBase_ClawbackNotAllowed(uint256 blockTimestamp, uint40 expiration, uint40 firstClaimTime);

    /// @notice Thrown if fee transfer fails.
    error StreamArcMerkleBase_FeeTransferFailed(address feeRecipient, uint256 feeAmount);

    /// @notice Thrown when trying to claim the same index more than once.
    error StreamArcMerkleBase_IndexClaimed(uint256 index);

    /// @notice Thrown when trying to claim without paying the min fee.
    error StreamArcMerkleBase_InsufficientFeePayment(uint256 feePaid, uint256 minFeeWei);

    /// @notice Thrown when trying to claim with an invalid Merkle proof.
    error StreamArcMerkleBase_InvalidProof();

    /// @notice Thrown when trying to set a new min USD fee that is higher than the current fee.
    error StreamArcMerkleBase_NewMinFeeUSDNotLower(uint256 currentMinFeeUSD, uint256 newMinFeeUSD);

    /// @notice Thrown when trying to sponsor with a zero amount.
    error StreamArcMerkleBase_SponsorAmountZero();

    /// @notice Thrown when trying to claim to the zero address.
    error StreamArcMerkleBase_ToZeroAddress();

    /// @notice Thrown when trying to call a claim function not supported in the campaign.
    error StreamArcMerkleBase_UnsupportedClaimType(ClaimType claimTypeRequired, ClaimType claimTypeSupported);

    /*//////////////////////////////////////////////////////////////////////////
                               STREAMARC-MERKLE-EXECUTE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the transferred amount is not equal to the claim amount during `claimAndExecute`.
    error StreamArcMerkleExecute_NotFullAmountTransferred(uint256 amountTransferred, uint256 claimAmount);

    /*//////////////////////////////////////////////////////////////////////////
                              STREAMARC-MERKLE-SIGNATURE
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the attestation signature has expired.
    error StreamArcMerkleSignature_AttestationExpired(uint256 expireAt, uint256 blockTimestamp);

    /// @notice Thrown when the attestor returns the zero address.
    error StreamArcMerkleSignature_AttestorNotSet();

    /// @notice Thrown when caller is not the comptroller or campaign admin.
    error StreamArcMerkleSignature_CallerNotAuthorized(address caller, address campaignAdmin, address comptroller);

    /// @notice Thrown when claiming with an invalid EIP-712 or EIP-1271 signature.
    error StreamArcMerkleSignature_InvalidSignature();

    /// @notice Thrown when trying to claim with a signature that is not yet valid.
    error StreamArcMerkleSignature_SignatureNotYetValid(uint40 validFrom, uint40 blockTimestamp);

    /*//////////////////////////////////////////////////////////////////////////
                                 STREAMARC-MERKLE-VCA
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Thrown when the claim amount is zero.
    error StreamArcMerkleVCA_ClaimAmountZero(address recipient);

    /// @notice Thrown when trying to switch to redistribute strategy when already using it.
    error StreamArcMerkleVCA_RedistributionAlreadyEnabled();

    /// @notice Thrown when trying to calculate the rewards amount without redistribution enabled.
    error StreamArcMerkleVCA_RedistributionNotEnabled();

    /// @notice Thrown when trying to enable redistribution after the vesting end time.
    error StreamArcMerkleVCA_VestingEndTimeNotInFuture(uint256 vestingEndTime, uint256 blockTimestamp);

    /// @notice Thrown when calculating the forgone amount with claim time less than the vesting start time.
    error StreamArcMerkleVCA_VestingNotStarted(uint40 claimTime, uint40 vestingStartTime);
}
