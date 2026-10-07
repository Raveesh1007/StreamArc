// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { BaseScript } from "@streamarc/evm-utils/src/tests/BaseScript.sol";

import { LockupNFTDescriptor } from "../../src/LockupNFTDescriptor.sol";
import { StreamArcBatchLockup } from "../../src/StreamArcBatchLockup.sol";
import { StreamArcLockup } from "../../src/StreamArcLockup.sol";

import { LockupNFTDescriptorAddresses } from "./LockupNFTDescriptorAddresses.sol";

/// @notice Deploys the Lockup Protocol at deterministic addresses across chains.
contract DeployDeterministicProtocol is BaseScript, LockupNFTDescriptorAddresses {
    string internal constant DEPLOYMENT_VERSION = "4.0.0";

    /// @dev Deploys the protocol.
    function run()
        public
        broadcast
        returns (StreamArcLockup lockup, StreamArcBatchLockup batchLockup, LockupNFTDescriptor nftDescriptor)
    {
        // If the contract is not already deployed, deploy it.
        if (nftDescriptorAddress() == address(0)) {
            // Use just the version as salt as we want to deploy at the same address across all chains.
            bytes32 nftDescriptorSalt = bytes32(abi.encodePacked(getVersion()));

            nftDescriptor = new LockupNFTDescriptor{ salt: nftDescriptorSalt }();
        }
        // Otherwise, use the address of the existing contract.
        else {
            nftDescriptor = LockupNFTDescriptor(nftDescriptorAddress());
        }

        batchLockup = new StreamArcBatchLockup{ salt: SALT }();
        lockup = new StreamArcLockup{ salt: SALT }(getComptroller(), address(nftDescriptor));
    }

    function getVersion() public pure override returns (string memory) {
        return DEPLOYMENT_VERSION;
    }
}
