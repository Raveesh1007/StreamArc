// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { Script } from "forge-std/src/Script.sol";
import { console2 } from "forge-std/src/console2.sol";

import { FlowNFTDescriptor } from "../../../src/FlowNFTDescriptor.sol";
import { StreamArcFlow } from "../../../src/StreamArcFlow.sol";

/// @notice Deploys Flow (open-ended streams) and the Flow NFT descriptor on Arc.
/// @dev Env: COMPTROLLER (address from DeployArcComptroller).
contract DeployArcFlow is Script {
    function run() public returns (StreamArcFlow flow, FlowNFTDescriptor nftDescriptor) {
        address comptroller = vm.envAddress("COMPTROLLER");
        vm.startBroadcast();
        nftDescriptor = new FlowNFTDescriptor();
        flow = new StreamArcFlow(comptroller, address(nftDescriptor));
        vm.stopBroadcast();

        console2.log("StreamArcFlow:       ", address(flow));
        console2.log("FlowNFTDescriptor: ", address(nftDescriptor));
    }
}
