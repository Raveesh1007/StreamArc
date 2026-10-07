// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { BaseScript as EvmUtilsBaseScript } from "@streamarc/evm-utils/src/tests/BaseScript.sol";

import { StreamArcFactoryMerkleExecute } from "../../src/StreamArcFactoryMerkleExecute.sol";
import { StreamArcFactoryMerkleInstant } from "../../src/StreamArcFactoryMerkleInstant.sol";
import { StreamArcFactoryMerkleLL } from "../../src/StreamArcFactoryMerkleLL.sol";
import { StreamArcFactoryMerkleLT } from "../../src/StreamArcFactoryMerkleLT.sol";
import { StreamArcFactoryMerkleVCA } from "../../src/StreamArcFactoryMerkleVCA.sol";

/// @notice Deploys the FactoryMerkle contracts at deterministic addresses.
/// @dev Reverts if any contract has already been deployed.
contract DeployDeterministicFactories is EvmUtilsBaseScript {
    string internal constant DEPLOYMENT_VERSION = "3.0.0";

    /// @dev Deploy via Forge.
    function run()
        public
        broadcast
        returns (
            StreamArcFactoryMerkleExecute factoryMerkleExecute,
            StreamArcFactoryMerkleInstant factoryMerkleInstant,
            StreamArcFactoryMerkleLL factoryMerkleLL,
            StreamArcFactoryMerkleLT factoryMerkleLT,
            StreamArcFactoryMerkleVCA factoryMerkleVCA
        )
    {
        factoryMerkleExecute = new StreamArcFactoryMerkleExecute{ salt: SALT }(getComptroller());
        factoryMerkleInstant = new StreamArcFactoryMerkleInstant{ salt: SALT }(getComptroller());
        factoryMerkleLL = new StreamArcFactoryMerkleLL{ salt: SALT }(getComptroller());
        factoryMerkleLT = new StreamArcFactoryMerkleLT{ salt: SALT }(getComptroller());
        factoryMerkleVCA = new StreamArcFactoryMerkleVCA{ salt: SALT }(getComptroller());
    }

    function getVersion() public pure override returns (string memory) {
        return DEPLOYMENT_VERSION;
    }
}
