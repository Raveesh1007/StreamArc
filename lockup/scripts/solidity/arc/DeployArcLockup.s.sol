// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22 <0.9.0;

import { Script } from "forge-std/src/Script.sol";
import { console2 } from "forge-std/src/console2.sol";

import { LockupNFTDescriptor } from "../../../src/LockupNFTDescriptor.sol";
import { StreamArcBatchLockup } from "../../../src/StreamArcBatchLockup.sol";
import { StreamArcLockup } from "../../../src/StreamArcLockup.sol";

/// @notice Deploys Lockup (vesting), BatchLockup and the Lockup NFT descriptor on Arc.
/// @dev Env: COMPTROLLER (address from DeployArcComptroller).
contract DeployArcLockup is Script {
    function run()
        public
        returns (StreamArcLockup lockup, StreamArcBatchLockup batchLockup, LockupNFTDescriptor nftDescriptor)
    {
        address comptroller = vm.envAddress("COMPTROLLER");
        vm.startBroadcast();
        nftDescriptor = new LockupNFTDescriptor();
        batchLockup = new StreamArcBatchLockup();
        lockup = new StreamArcLockup(comptroller, address(nftDescriptor));
        vm.stopBroadcast();

        console2.log("StreamArcLockup:       ", address(lockup));
        console2.log("StreamArcBatchLockup:  ", address(batchLockup));
        console2.log("LockupNFTDescriptor: ", address(nftDescriptor));
    }
}
