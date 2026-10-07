#!/usr/bin/env bash

# Pre-requisites:
# - foundry (https://getfoundry.sh)
# - bun (https://bun.sh)

# Strict mode: https://gist.github.com/vncsna/64825d5609c146e80de8b1fd623011ca
set -euo pipefail

# Generate the artifacts with Forge
FOUNDRY_PROFILE=optimized forge build

# Delete the current artifacts
artifacts=./artifacts
rm -rf $artifacts

# Create the new artifacts directories
mkdir $artifacts \
  "$artifacts/erc20" \
  "$artifacts/interfaces" \
  "$artifacts/libraries"

cp out-optimized/StreamArcFactoryMerkleExecute.sol/StreamArcFactoryMerkleExecute.json $artifacts
cp out-optimized/StreamArcFactoryMerkleInstant.sol/StreamArcFactoryMerkleInstant.json $artifacts
cp out-optimized/StreamArcFactoryMerkleLL.sol/StreamArcFactoryMerkleLL.json $artifacts
cp out-optimized/StreamArcFactoryMerkleLT.sol/StreamArcFactoryMerkleLT.json $artifacts
cp out-optimized/StreamArcFactoryMerkleVCA.sol/StreamArcFactoryMerkleVCA.json $artifacts
cp out-optimized/StreamArcMerkleExecute.sol/StreamArcMerkleExecute.json $artifacts
cp out-optimized/StreamArcMerkleInstant.sol/StreamArcMerkleInstant.json $artifacts
cp out-optimized/StreamArcMerkleLL.sol/StreamArcMerkleLL.json $artifacts
cp out-optimized/StreamArcMerkleLT.sol/StreamArcMerkleLT.json $artifacts
cp out-optimized/StreamArcMerkleVCA.sol/StreamArcMerkleVCA.json $artifacts
cp out-optimized/SignatureHash.sol/SignatureHash.json $artifacts

interfaces=./artifacts/interfaces
cp out-optimized/IStreamArcFactoryMerkleExecute.sol/IStreamArcFactoryMerkleExecute.json $interfaces
cp out-optimized/IStreamArcFactoryMerkleInstant.sol/IStreamArcFactoryMerkleInstant.json $interfaces
cp out-optimized/IStreamArcFactoryMerkleLL.sol/IStreamArcFactoryMerkleLL.json $interfaces
cp out-optimized/IStreamArcFactoryMerkleLT.sol/IStreamArcFactoryMerkleLT.json $interfaces
cp out-optimized/IStreamArcFactoryMerkleVCA.sol/IStreamArcFactoryMerkleVCA.json $interfaces
cp out-optimized/IStreamArcMerkleExecute.sol/IStreamArcMerkleExecute.json $interfaces
cp out-optimized/IStreamArcMerkleInstant.sol/IStreamArcMerkleInstant.json $interfaces
cp out-optimized/IStreamArcMerkleLL.sol/IStreamArcMerkleLL.json $interfaces
cp out-optimized/IStreamArcMerkleLT.sol/IStreamArcMerkleLT.json $interfaces
cp out-optimized/IStreamArcMerkleVCA.sol/IStreamArcMerkleVCA.json $interfaces

libraries=./artifacts/libraries
cp out-optimized/libraries/Errors.sol/Errors.json $libraries

################################################
####                OTHERS                  ####
################################################

erc20=./artifacts/erc20
cp out-optimized/IERC20.sol/IERC20.json $erc20

# Format the artifacts with Prettier
bun prettier --write ./artifacts
