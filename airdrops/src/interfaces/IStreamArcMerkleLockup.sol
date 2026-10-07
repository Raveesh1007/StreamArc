// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IStreamArcLockup } from "@streamarc/lockup/src/interfaces/IStreamArcLockup.sol";

import { IStreamArcMerkleBase } from "./IStreamArcMerkleBase.sol";

/// @title IStreamArcMerkleLockup
/// @notice MerkleLockup enables Airstreams (a portmanteau of "airdrop" and "stream"), an airdrop model where the
/// tokens are vested over time, as opposed to being unlocked at once. The vesting is provided by StreamArc Lockup.
/// @dev Common interface between MerkleLL and MerkleLT.
interface IStreamArcMerkleLockup is IStreamArcMerkleBase {
    /*//////////////////////////////////////////////////////////////////////////
                                READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice The address of the {StreamArcLockup} contract.
    function STREAMARC_LOCKUP() external view returns (IStreamArcLockup);

    /// @notice A flag indicating whether the streams can be canceled.
    /// @dev This is an immutable state variable.
    function STREAM_CANCELABLE() external view returns (bool);

    /// @notice A flag indicating whether the stream NFTs are transferable.
    /// @dev This is an immutable state variable.
    function STREAM_TRANSFERABLE() external view returns (bool);

    /// @notice Retrieves the stream IDs associated with the airdrops claimed by the provided recipient.
    /// In practice, most campaigns will only have one stream per recipient.
    function claimedStreams(address recipient) external view returns (uint256[] memory);

    /// @notice Retrieves the shape of the Lockup stream created upon claiming.
    function streamShape() external view returns (string memory);
}
