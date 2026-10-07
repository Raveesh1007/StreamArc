// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { BaseScript } from "@streamarc/evm-utils/src/tests/BaseScript.sol";

import { StreamArcBatchLockup } from "../../src/StreamArcBatchLockup.sol";

contract DeployDeterministicBatchLockup is BaseScript {
    /// @dev Deploy via Forge.
    function run() public broadcast returns (StreamArcBatchLockup batchLockup) {
        batchLockup = new StreamArcBatchLockup{ salt: SALT }();
    }
}
