// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { BaseScript } from "@streamarc/evm-utils/src/tests/BaseScript.sol";

import { StreamArcFlow } from "../../src/StreamArcFlow.sol";

/// @notice Deploys {StreamArcFlow}.
contract DeployFlow is BaseScript {
    function run(address nftDescriptor) public broadcast returns (StreamArcFlow flow) {
        flow = new StreamArcFlow(getComptroller(), nftDescriptor);
    }
}
