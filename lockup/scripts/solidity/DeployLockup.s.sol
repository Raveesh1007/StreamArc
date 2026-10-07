// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { BaseScript } from "@streamarc/evm-utils/src/tests/BaseScript.sol";

import { ILockupNFTDescriptor } from "../../src/interfaces/ILockupNFTDescriptor.sol";
import { StreamArcLockup } from "../../src/StreamArcLockup.sol";

/// @notice Deploys {StreamArcLockup} contract.
contract DeployLockup is BaseScript {
    function run(ILockupNFTDescriptor nftDescriptor) public broadcast returns (StreamArcLockup lockup) {
        lockup = new StreamArcLockup(getComptroller(), address(nftDescriptor));
    }
}
