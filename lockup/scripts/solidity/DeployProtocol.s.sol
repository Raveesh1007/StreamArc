// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { BaseScript } from "@streamarc/evm-utils/src/tests/BaseScript.sol";

import { LockupNFTDescriptor } from "../../src/LockupNFTDescriptor.sol";
import { StreamArcBatchLockup } from "../../src/StreamArcBatchLockup.sol";
import { StreamArcLockup } from "../../src/StreamArcLockup.sol";

import { LockupNFTDescriptorAddresses } from "./LockupNFTDescriptorAddresses.sol";

/// @notice Deploys the Lockup Protocol.
contract DeployProtocol is BaseScript, LockupNFTDescriptorAddresses {
    /// @dev Deploys the protocol.
    function run()
        public
        broadcast
        returns (StreamArcLockup lockup, StreamArcBatchLockup batchLockup, LockupNFTDescriptor nftDescriptor)
    {
        // If the contract is not already deployed, deploy it.
        if (nftDescriptorAddress() == address(0)) {
            nftDescriptor = new LockupNFTDescriptor();
        }
        // Otherwise, use the address of the existing contract.
        else {
            nftDescriptor = LockupNFTDescriptor(nftDescriptorAddress());
        }

        batchLockup = new StreamArcBatchLockup();
        lockup = new StreamArcLockup(getComptroller(), address(nftDescriptor));
    }
}
