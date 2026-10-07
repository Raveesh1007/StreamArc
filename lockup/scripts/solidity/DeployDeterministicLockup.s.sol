// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { BaseScript } from "@streamarc/evm-utils/src/tests/BaseScript.sol";

import { LockupNFTDescriptor } from "../../src/LockupNFTDescriptor.sol";
import { StreamArcLockup } from "../../src/StreamArcLockup.sol";

import { LockupNFTDescriptorAddresses } from "./LockupNFTDescriptorAddresses.sol";

/// @notice Deploys {StreamArcLockup} at a deterministic address across chains.
/// @dev Reverts if the contract has already been deployed.
contract DeployDeterministicLockup is BaseScript, LockupNFTDescriptorAddresses {
    function run() public broadcast returns (StreamArcLockup lockup, LockupNFTDescriptor nftDescriptor) {
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

        lockup = new StreamArcLockup{ salt: SALT }(getComptroller(), address(nftDescriptor));
    }
}
