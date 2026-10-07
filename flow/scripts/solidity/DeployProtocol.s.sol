// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { BaseScript } from "@streamarc/evm-utils/src/tests/BaseScript.sol";

import { FlowNFTDescriptor } from "../../src/FlowNFTDescriptor.sol";
import { StreamArcFlow } from "../../src/StreamArcFlow.sol";

import { FlowNFTDescriptorAddresses } from "./FlowNFTDescriptorAddresses.sol";

/// @notice Deploys the protocol.
contract DeployProtocol is BaseScript, FlowNFTDescriptorAddresses {
    function run() public broadcast returns (StreamArcFlow flow, FlowNFTDescriptor nftDescriptor) {
        // If the contract is not already deployed, deploy it.
        if (nftDescriptorAddress() == address(0)) {
            nftDescriptor = new FlowNFTDescriptor();
        }
        // Otherwise, use the address of the existing contract.
        else {
            nftDescriptor = FlowNFTDescriptor(nftDescriptorAddress());
        }

        flow = new StreamArcFlow(getComptroller(), address(nftDescriptor));
    }
}
