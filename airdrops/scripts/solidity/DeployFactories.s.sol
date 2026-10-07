// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { BaseScript as EvmUtilsBaseScript } from "@streamarc/evm-utils/src/tests/BaseScript.sol";

import { StreamArcFactoryMerkleExecute } from "../../src/StreamArcFactoryMerkleExecute.sol";
import { StreamArcFactoryMerkleInstant } from "../../src/StreamArcFactoryMerkleInstant.sol";
import { StreamArcFactoryMerkleLL } from "../../src/StreamArcFactoryMerkleLL.sol";
import { StreamArcFactoryMerkleLT } from "../../src/StreamArcFactoryMerkleLT.sol";
import { StreamArcFactoryMerkleVCA } from "../../src/StreamArcFactoryMerkleVCA.sol";

/// @notice Deploys the FactoryMerkle contracts.
contract DeployFactories is EvmUtilsBaseScript {
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
        factoryMerkleExecute = new StreamArcFactoryMerkleExecute(getComptroller());
        factoryMerkleInstant = new StreamArcFactoryMerkleInstant(getComptroller());
        factoryMerkleLL = new StreamArcFactoryMerkleLL(getComptroller());
        factoryMerkleLT = new StreamArcFactoryMerkleLT(getComptroller());
        factoryMerkleVCA = new StreamArcFactoryMerkleVCA(getComptroller());
    }
}
