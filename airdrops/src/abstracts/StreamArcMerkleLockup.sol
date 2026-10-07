// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { IStreamArcLockup } from "@streamarc/lockup/src/interfaces/IStreamArcLockup.sol";

import { IStreamArcMerkleLockup } from "../interfaces/IStreamArcMerkleLockup.sol";
import { MerkleLockup } from "../types/MerkleLockup.sol";
import { StreamArcMerkleBase } from "./StreamArcMerkleBase.sol";

/// @title StreamArcMerkleLockup
/// @notice See the documentation in {IStreamArcMerkleLockup}.
abstract contract StreamArcMerkleLockup is
    IStreamArcMerkleLockup, // 2 inherited components
    StreamArcMerkleBase // 3 inherited components
{
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamArcMerkleLockup
    IStreamArcLockup public immutable override STREAMARC_LOCKUP;

    /// @inheritdoc IStreamArcMerkleLockup
    bool public immutable override STREAM_CANCELABLE;

    /// @inheritdoc IStreamArcMerkleLockup
    bool public immutable override STREAM_TRANSFERABLE;

    /// @inheritdoc IStreamArcMerkleLockup
    string public override streamShape;

    /// @dev A mapping between recipient addresses and Lockup streams created through the claim function.
    mapping(address recipient => uint256[] streamIds) internal _claimedStreams;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Constructs the contract by initializing the immutable state vars, and max approving the Lockup contract.
    constructor(MerkleLockup.ConstructorParams memory lockupParams) {
        STREAMARC_LOCKUP = lockupParams.lockup;
        STREAM_CANCELABLE = lockupParams.cancelable;
        STREAM_TRANSFERABLE = lockupParams.transferable;
        streamShape = lockupParams.shape;

        // Max approve the Lockup contract to spend funds from the Merkle Lockup campaigns.
        TOKEN.forceApprove({ spender: address(STREAMARC_LOCKUP), value: type(uint256).max });
    }

    /*//////////////////////////////////////////////////////////////////////////
                          USER-FACING READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamArcMerkleLockup
    function claimedStreams(address recipient) external view override returns (uint256[] memory) {
        return _claimedStreams[recipient];
    }
}
