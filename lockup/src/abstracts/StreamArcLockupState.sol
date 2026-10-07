// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { ILockupNFTDescriptor } from "../interfaces/ILockupNFTDescriptor.sol";
import { IStreamArcLockupState } from "../interfaces/IStreamArcLockupState.sol";
import { Errors } from "../libraries/Errors.sol";
import { Lockup } from "../types/Lockup.sol";
import { LockupDynamic } from "../types/LockupDynamic.sol";
import { LockupLinear } from "../types/LockupLinear.sol";
import { LockupPriceGated } from "../types/LockupPriceGated.sol";
import { LockupTranched } from "../types/LockupTranched.sol";

/// @title StreamArcLockupState
/// @notice See the documentation in {IStreamArcLockupState}.
abstract contract StreamArcLockupState is IStreamArcLockupState {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamArcLockupState
    mapping(IERC20 token => uint256 amount) public override aggregateAmount;

    /// @inheritdoc IStreamArcLockupState
    address public override nativeToken;

    /// @inheritdoc IStreamArcLockupState
    uint256 public override nextStreamId;

    /// @inheritdoc IStreamArcLockupState
    ILockupNFTDescriptor public override nftDescriptor;

    /// @dev Mapping of contracts allowed to hook to StreamArc when a stream is canceled or when tokens are withdrawn.
    mapping(address recipient => bool allowed) internal _allowedToHook;

    /// @dev Cliff timestamp mapped by stream IDs, used in LL streams.
    mapping(uint256 streamId => uint40 cliffTime) internal _cliffs;

    /// @dev Granularity mapped by stream IDs, used in LL streams.
    mapping(uint256 streamId => uint40 granularity) internal _granularities;

    /// @dev Unlock parameters mapped by stream IDs, used in LPG streams.
    mapping(uint256 streamId => LockupPriceGated.UnlockParams unlockParams) internal _priceGatedUnlockParams;

    /// @dev Stream segments mapped by stream IDs, used in LD streams.
    mapping(uint256 streamId => LockupDynamic.Segment[] segments) internal _segments;

    /// @dev Lockup streams mapped by unsigned integers.
    mapping(uint256 id => Lockup.Stream stream) internal _streams;

    /// @dev Stream tranches mapped by stream IDs, used in LT streams.
    mapping(uint256 streamId => LockupTranched.Tranche[] tranches) internal _tranches;

    /// @dev Unlock amounts mapped by stream IDs, used in LL streams.
    mapping(uint256 streamId => LockupLinear.UnlockAmounts unlockAmounts) internal _unlockAmounts;

    /*//////////////////////////////////////////////////////////////////////////
                                     MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Checks that actual model and expected model are equal.
    modifier modelCheck(Lockup.Model actualModel, Lockup.Model expectedModel) {
        _modelCheck(actualModel, expectedModel);
        _;
    }

    /// @dev Checks that `streamId` does not reference a null stream.
    modifier notNull(uint256 streamId) {
        _notNull(streamId);
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @param initialNFTDescriptor The address of the initial NFT descriptor.
    constructor(address initialNFTDescriptor) {
        // Set the next stream to 1.
        nextStreamId = 1;

        // Set the NFT Descriptor.
        nftDescriptor = ILockupNFTDescriptor(initialNFTDescriptor);
    }

    /*//////////////////////////////////////////////////////////////////////////
                          USER-FACING READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamArcLockupState
    function getCliffTime(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        modelCheck(_streams[streamId].lockupModel, Lockup.Model.LOCKUP_LINEAR)
        returns (uint40 cliffTime)
    {
        cliffTime = _cliffs[streamId];
    }

    /// @inheritdoc IStreamArcLockupState
    function getDepositedAmount(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        returns (uint128 depositedAmount)
    {
        depositedAmount = _streams[streamId].amounts.deposited;
    }

    /// @inheritdoc IStreamArcLockupState
    function getEndTime(uint256 streamId) external view override notNull(streamId) returns (uint40 endTime) {
        endTime = _streams[streamId].endTime;
    }

    /// @inheritdoc IStreamArcLockupState
    function getGranularity(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        modelCheck(_streams[streamId].lockupModel, Lockup.Model.LOCKUP_LINEAR)
        returns (uint40 granularity)
    {
        granularity = _granularities[streamId];
    }

    /// @inheritdoc IStreamArcLockupState
    function getLockupModel(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        returns (Lockup.Model lockupModel)
    {
        lockupModel = _streams[streamId].lockupModel;
    }

    /// @inheritdoc IStreamArcLockupState
    function getPriceGatedUnlockParams(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        modelCheck(_streams[streamId].lockupModel, Lockup.Model.LOCKUP_PRICE_GATED)
        returns (LockupPriceGated.UnlockParams memory unlockParams)
    {
        unlockParams = _priceGatedUnlockParams[streamId];
    }

    /// @inheritdoc IStreamArcLockupState
    function getRefundedAmount(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        returns (uint128 refundedAmount)
    {
        refundedAmount = _streams[streamId].amounts.refunded;
    }

    /// @inheritdoc IStreamArcLockupState
    function getSegments(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        modelCheck(_streams[streamId].lockupModel, Lockup.Model.LOCKUP_DYNAMIC)
        returns (LockupDynamic.Segment[] memory segments)
    {
        segments = _segments[streamId];
    }

    /// @inheritdoc IStreamArcLockupState
    function getSender(uint256 streamId) external view override notNull(streamId) returns (address sender) {
        sender = _streams[streamId].sender;
    }

    /// @inheritdoc IStreamArcLockupState
    function getStartTime(uint256 streamId) external view override notNull(streamId) returns (uint40 startTime) {
        startTime = _streams[streamId].startTime;
    }

    /// @inheritdoc IStreamArcLockupState
    function getTranches(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        modelCheck(_streams[streamId].lockupModel, Lockup.Model.LOCKUP_TRANCHED)
        returns (LockupTranched.Tranche[] memory tranches)
    {
        tranches = _tranches[streamId];
    }

    /// @inheritdoc IStreamArcLockupState
    function getUnderlyingToken(uint256 streamId) external view override notNull(streamId) returns (IERC20 token) {
        token = _streams[streamId].token;
    }

    /// @inheritdoc IStreamArcLockupState
    function getUnlockAmounts(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        modelCheck(_streams[streamId].lockupModel, Lockup.Model.LOCKUP_LINEAR)
        returns (LockupLinear.UnlockAmounts memory unlockAmounts)
    {
        unlockAmounts = _unlockAmounts[streamId];
    }

    /// @inheritdoc IStreamArcLockupState
    function getWithdrawnAmount(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        returns (uint128 withdrawnAmount)
    {
        withdrawnAmount = _streams[streamId].amounts.withdrawn;
    }

    /// @inheritdoc IStreamArcLockupState
    function isAllowedToHook(address recipient) external view returns (bool result) {
        result = _allowedToHook[recipient];
    }

    /// @inheritdoc IStreamArcLockupState
    function isCancelable(uint256 streamId) external view override notNull(streamId) returns (bool result) {
        if (_statusOf(streamId) != Lockup.Status.SETTLED) {
            result = _streams[streamId].isCancelable;
        }
    }

    /// @inheritdoc IStreamArcLockupState
    function isDepleted(uint256 streamId) external view override notNull(streamId) returns (bool result) {
        result = _streams[streamId].isDepleted;
    }

    /// @inheritdoc IStreamArcLockupState
    function isStream(uint256 streamId) external view override returns (bool result) {
        // Since {LockupHelpers._checkCreateStream} reverts if the sender address is zero, this can be used to check
        // whether the stream exists.
        result = _streams[streamId].sender != address(0);
    }

    /// @inheritdoc IStreamArcLockupState
    function isTransferable(uint256 streamId) external view override notNull(streamId) returns (bool result) {
        result = _streams[streamId].isTransferable;
    }

    /// @inheritdoc IStreamArcLockupState
    function wasCanceled(uint256 streamId) external view override notNull(streamId) returns (bool result) {
        result = _streams[streamId].wasCanceled;
    }

    /*//////////////////////////////////////////////////////////////////////////
                             INTERNAL READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Retrieves the stream's status without performing a null check.
    function _statusOf(uint256 streamId) internal view returns (Lockup.Status) {
        if (_streams[streamId].isDepleted) {
            return Lockup.Status.DEPLETED;
        } else if (_streams[streamId].wasCanceled) {
            return Lockup.Status.CANCELED;
        }

        if (block.timestamp < _streams[streamId].startTime) {
            return Lockup.Status.PENDING;
        }

        if (_streamedAmountOf(streamId) < _streams[streamId].amounts.deposited) {
            return Lockup.Status.STREAMING;
        } else {
            return Lockup.Status.SETTLED;
        }
    }

    /// @notice Calculates the streamed amount of the stream.
    /// @dev This function is implemented by child contract. The logic varies according to the distribution model.
    function _streamedAmountOf(uint256 streamId) internal view virtual returns (uint128);

    /*//////////////////////////////////////////////////////////////////////////
                         INTERNAL STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice This function is implemented by {StreamArcLockup} and is used in the {StreamArcLockupDynamic},
    /// {StreamArcLockupLinear} and {StreamArcLockupTranched} contracts.
    /// @dev It updates state variables based on the stream parameters, mints an NFT to the recipient, bumps stream ID,
    /// and transfers the deposit amount.
    function _create(
        bool cancelable,
        uint128 depositAmount,
        Lockup.Model lockupModel,
        address recipient,
        address sender,
        uint256 streamId,
        Lockup.Timestamps memory timestamps,
        IERC20 token,
        bool transferable
    )
        internal
        virtual { }

    /*//////////////////////////////////////////////////////////////////////////
                             PRIVATE READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Reverts if actual model and expected model are not equal.
    function _modelCheck(Lockup.Model actualModel, Lockup.Model expectedModel) private pure {
        if (actualModel != expectedModel) {
            revert Errors.StreamArcLockupState_NotExpectedModel(actualModel, expectedModel);
        }
    }

    /// @dev A private function is used instead of inlining this logic in a 3 because Solidity copies modifiers
    /// into every function that uses them.
    function _notNull(uint256 streamId) private view {
        // Since {LockupHelpers._checkCreateStream} reverts if the sender address is zero, this can be used to check
        // whether the stream exists.
        if (_streams[streamId].sender == address(0)) {
            revert Errors.StreamArcLockupState_Null(streamId);
        }
    }
}
