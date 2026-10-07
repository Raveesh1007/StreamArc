// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { StdCheats } from "forge-std/src/StdCheats.sol";

import { IStreamArcFactoryMerkleExecute } from "../../src/interfaces/IStreamArcFactoryMerkleExecute.sol";
import { IStreamArcFactoryMerkleInstant } from "../../src/interfaces/IStreamArcFactoryMerkleInstant.sol";
import { IStreamArcFactoryMerkleLL } from "../../src/interfaces/IStreamArcFactoryMerkleLL.sol";
import { IStreamArcFactoryMerkleLT } from "../../src/interfaces/IStreamArcFactoryMerkleLT.sol";
import { IStreamArcFactoryMerkleVCA } from "../../src/interfaces/IStreamArcFactoryMerkleVCA.sol";

abstract contract DeployOptimized is StdCheats {
    function deployOptimizedFactories(address initialComptroller)
        internal
        returns (
            IStreamArcFactoryMerkleExecute factoryMerkleExecute,
            IStreamArcFactoryMerkleInstant factoryMerkleInstant,
            IStreamArcFactoryMerkleLL factoryMerkleLL,
            IStreamArcFactoryMerkleLT factoryMerkleLT,
            IStreamArcFactoryMerkleVCA factoryMerkleVCA
        )
    {
        factoryMerkleExecute = IStreamArcFactoryMerkleExecute(
            deployCode(
                "out-optimized/StreamArcFactoryMerkleExecute.sol/StreamArcFactoryMerkleExecute.json",
                abi.encode(initialComptroller)
            )
        );
        factoryMerkleInstant = IStreamArcFactoryMerkleInstant(
            deployCode(
                "out-optimized/StreamArcFactoryMerkleInstant.sol/StreamArcFactoryMerkleInstant.json",
                abi.encode(initialComptroller)
            )
        );
        factoryMerkleLL = IStreamArcFactoryMerkleLL(
            deployCode(
                "out-optimized/StreamArcFactoryMerkleLL.sol/StreamArcFactoryMerkleLL.json", abi.encode(initialComptroller)
            )
        );
        factoryMerkleLT = IStreamArcFactoryMerkleLT(
            deployCode(
                "out-optimized/StreamArcFactoryMerkleLT.sol/StreamArcFactoryMerkleLT.json", abi.encode(initialComptroller)
            )
        );
        factoryMerkleVCA = IStreamArcFactoryMerkleVCA(
            deployCode(
                "out-optimized/StreamArcFactoryMerkleVCA.sol/StreamArcFactoryMerkleVCA.json", abi.encode(initialComptroller)
            )
        );
    }
}
