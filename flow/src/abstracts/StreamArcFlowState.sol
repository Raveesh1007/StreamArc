// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { UD21x18 } from "@prb/math/src/UD21x18.sol";

import { IFlowNFTDescriptor } from "./../interfaces/IFlowNFTDescriptor.sol";
import { IStreamArcFlowState } from "./../interfaces/IStreamArcFlowState.sol";
import { Errors } from "./../libraries/Errors.sol";
import { Flow } from "./../types/DataTypes.sol";

/// @title StreamArcFlowState
/// @notice See the documentation in {IStreamArcFlowState}.
abstract contract StreamArcFlowState is IStreamArcFlowState {
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamArcFlowState
    mapping(IERC20 token => uint256 amount) public override aggregateAmount;

    /// @inheritdoc IStreamArcFlowState
    address public override nativeToken;

    /// @inheritdoc IStreamArcFlowState
    uint256 public override nextStreamId;

    /// @inheritdoc IStreamArcFlowState
    IFlowNFTDescriptor public override nftDescriptor;

    /// @dev StreamArc Flow streams mapped by unsigned integers.
    mapping(uint256 id => Flow.Stream stream) internal _streams;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @param initialNFTDescriptor The address of the initial NFT descriptor.
    constructor(address initialNFTDescriptor) {
        nextStreamId = 1;
        nftDescriptor = IFlowNFTDescriptor(initialNFTDescriptor);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Checks that `streamId` does not reference a null stream.
    modifier notNull(uint256 streamId) {
        _notNull(streamId);
        _;
    }

    /// @dev Checks that `streamId` does not reference a paused stream. Note that this implicitly checks that the stream
    /// is not voided either.
    modifier notPaused(uint256 streamId) {
        if (_streams[streamId].ratePerSecond.unwrap() == 0) {
            revert Errors.StreamArcFlowState_StreamPaused(streamId);
        }
        _;
    }

    /// @dev Checks that `streamId` does not reference a voided stream.
    modifier notVoided(uint256 streamId) {
        if (_streams[streamId].isVoided) {
            revert Errors.StreamArcFlowState_StreamVoided(streamId);
        }
        _;
    }

    /// @dev Checks the `msg.sender` is the stream's sender.
    modifier onlySender(uint256 streamId) {
        if (msg.sender != _streams[streamId].sender) {
            revert Errors.StreamArcFlowState_Unauthorized(streamId, msg.sender);
        }
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                          USER-FACING READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamArcFlowState
    function getBalance(uint256 streamId) external view override notNull(streamId) returns (uint128 balance) {
        balance = _streams[streamId].balance;
    }

    /// @inheritdoc IStreamArcFlowState
    function getRatePerSecond(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        returns (UD21x18 ratePerSecond)
    {
        ratePerSecond = _streams[streamId].ratePerSecond;
    }

    /// @inheritdoc IStreamArcFlowState
    function getSender(uint256 streamId) external view override notNull(streamId) returns (address sender) {
        sender = _streams[streamId].sender;
    }

    /// @inheritdoc IStreamArcFlowState
    function getSnapshotDebtScaled(uint256 streamId)
        external
        view
        override
        notNull(streamId)
        returns (uint256 snapshotDebtScaled)
    {
        snapshotDebtScaled = _streams[streamId].snapshotDebtScaled;
    }

    /// @inheritdoc IStreamArcFlowState
    function getSnapshotTime(uint256 streamId) external view override notNull(streamId) returns (uint40 snapshotTime) {
        snapshotTime = _streams[streamId].snapshotTime;
    }

    /// @inheritdoc IStreamArcFlowState
    function getStream(uint256 streamId) external view override notNull(streamId) returns (Flow.Stream memory stream) {
        stream = _streams[streamId];
    }

    /// @inheritdoc IStreamArcFlowState
    function getToken(uint256 streamId) external view override notNull(streamId) returns (IERC20 token) {
        token = _streams[streamId].token;
    }

    /// @inheritdoc IStreamArcFlowState
    function getTokenDecimals(uint256 streamId) external view override notNull(streamId) returns (uint8 tokenDecimals) {
        tokenDecimals = _streams[streamId].tokenDecimals;
    }

    /// @inheritdoc IStreamArcFlowState
    function isStream(uint256 streamId) external view override returns (bool result) {
        result = _streams[streamId].isStream;
    }

    /// @inheritdoc IStreamArcFlowState
    function isTransferable(uint256 streamId) external view override notNull(streamId) returns (bool result) {
        result = _streams[streamId].isTransferable;
    }

    /// @inheritdoc IStreamArcFlowState
    function isVoided(uint256 streamId) external view override notNull(streamId) returns (bool result) {
        result = _streams[streamId].isVoided;
    }

    /*//////////////////////////////////////////////////////////////////////////
                            PRIVATE READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev A private function is used instead of inlining this logic in a modifier because Solidity copies modifiers
    /// into every function that uses them.
    function _notNull(uint256 streamId) private view {
        if (!_streams[streamId].isStream) {
            revert Errors.StreamArcFlowState_Null(streamId);
        }
    }
}
