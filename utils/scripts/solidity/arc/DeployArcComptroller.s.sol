// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

// solhint-disable no-console

import { Script } from "forge-std/src/Script.sol";
import { console2 } from "forge-std/src/console2.sol";

import { NonDeterministicComptrollerDeployer } from "../AtomicComptrollerDeployer.sol";

/// @notice Deploys the Comptroller (implementation + initialized proxy) on Arc.
/// @dev Arc has no Chainlink native/USD feed, so the oracle is left unset and all
///      protocol fees are zero, matching StreamArc's own initial fee setting.
///      Env: ARC_ADMIN (defaults to the broadcaster).
contract DeployArcComptroller is Script {
    function run() public returns (address proxy, address implementation) {
        vm.startBroadcast();
        (, address broadcaster,) = vm.readCallers();
        address admin = vm.envOr("ARC_ADMIN", broadcaster);

        NonDeterministicComptrollerDeployer deployer = new NonDeterministicComptrollerDeployer({
            initialAdmin: admin,
            initialMinFeeUSD: 0,
            initialOracle: address(0)
        });
        vm.stopBroadcast();

        proxy = deployer.PROXY();
        implementation = deployer.IMPLEMENTATION();
        console2.log("Comptroller proxy:         ", proxy);
        console2.log("Comptroller implementation:", implementation);
        console2.log("Admin:                     ", admin);
    }
}
