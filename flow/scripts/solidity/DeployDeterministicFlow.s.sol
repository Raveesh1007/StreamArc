// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { BaseScript } from "@streamarc/evm-utils/src/tests/BaseScript.sol";

import { FlowNFTDescriptor } from "../../src/FlowNFTDescriptor.sol";
import { StreamArcFlow } from "../../src/StreamArcFlow.sol";

import { FlowNFTDescriptorAddresses } from "./FlowNFTDescriptorAddresses.sol";

/// @notice Deploys {StreamArcFlow} at a deterministic address across chains.
/// @dev Reverts if the contract has already been deployed.
contract DeployDeterministicFlow is BaseScript, FlowNFTDescriptorAddresses {
    function run() public broadcast returns (StreamArcFlow flow, FlowNFTDescriptor nftDescriptor) {
        // If the contract is not already deployed, deploy it.
        if (nftDescriptorAddress() == address(0)) {
            // Use just the version as salt as we want to deploy at the same address across all chains.
            bytes32 nftDescriptorSalt = bytes32(abi.encodePacked(getVersion()));

            nftDescriptor = new FlowNFTDescriptor{ salt: nftDescriptorSalt }();
        }
        // Otherwise, use the address of the existing contract.
        else {
            nftDescriptor = FlowNFTDescriptor(nftDescriptorAddress());
        }

        flow = new StreamArcFlow{ salt: SALT }(getComptroller(), address(nftDescriptor));
    }
}
