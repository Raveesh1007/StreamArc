// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { Script } from "forge-std/src/Script.sol";
import { console2 } from "forge-std/src/console2.sol";

import { StreamArcFactoryMerkleExecute } from "../../../src/StreamArcFactoryMerkleExecute.sol";
import { StreamArcFactoryMerkleInstant } from "../../../src/StreamArcFactoryMerkleInstant.sol";
import { StreamArcFactoryMerkleLL } from "../../../src/StreamArcFactoryMerkleLL.sol";
import { StreamArcFactoryMerkleLT } from "../../../src/StreamArcFactoryMerkleLT.sol";
import { StreamArcFactoryMerkleVCA } from "../../../src/StreamArcFactoryMerkleVCA.sol";

/// @notice Deploys the five Merkle airdrop factories on Arc.
/// @dev Env: COMPTROLLER (address from DeployArcComptroller).
contract DeployArcAirdrops is Script {
    function run()
        public
        returns (
            StreamArcFactoryMerkleExecute execute_,
            StreamArcFactoryMerkleInstant instant,
            StreamArcFactoryMerkleLL ll,
            StreamArcFactoryMerkleLT lt,
            StreamArcFactoryMerkleVCA vca
        )
    {
        address comptroller = vm.envAddress("COMPTROLLER");
        vm.startBroadcast();
        execute_ = new StreamArcFactoryMerkleExecute(comptroller);
        instant = new StreamArcFactoryMerkleInstant(comptroller);
        ll = new StreamArcFactoryMerkleLL(comptroller);
        lt = new StreamArcFactoryMerkleLT(comptroller);
        vca = new StreamArcFactoryMerkleVCA(comptroller);
        vm.stopBroadcast();

        console2.log("FactoryMerkleExecute: ", address(execute_));
        console2.log("FactoryMerkleInstant: ", address(instant));
        console2.log("FactoryMerkleLL:      ", address(ll));
        console2.log("FactoryMerkleLT:      ", address(lt));
        console2.log("FactoryMerkleVCA:     ", address(vca));
    }
}
