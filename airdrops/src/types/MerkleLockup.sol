// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IStreamArcLockup } from "@streamarc/lockup/src/interfaces/IStreamArcLockup.sol";

library MerkleLockup {
    /// @notice Struct encapsulating the constructor parameters of {StreamArcMerkleLockup} contract.
    /// @dev The fields are arranged alphabetically.
    /// @param cancelable Whether Lockup stream will be cancelable after claiming.
    /// @param lockup The address of the {StreamArcLockup} contract.
    /// @param shape The shape of the vesting stream, used for differentiating between streams in the UI.
    /// @param transferable Whether Lockup stream will be transferable after claiming.
    struct ConstructorParams {
        bool cancelable;
        IStreamArcLockup lockup;
        string shape;
        bool transferable;
    }
}
