// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.29;

import { Script } from "forge-std/Script.sol";
import { console2 } from "forge-std/console2.sol";
import { PayrollVault, IERC20 } from "../src/PayrollVault.sol";

/// @notice Env: USDC (defaults to Arc's USDC ERC-20 interface).
contract DeployPayroll is Script {
    function run() external returns (PayrollVault vault) {
        address usdc = vm.envOr("USDC", address(0x3600000000000000000000000000000000000000));
        vm.startBroadcast();
        vault = new PayrollVault(IERC20(usdc));
        vm.stopBroadcast();
        console2.log("PayrollVault:", address(vault));
    }
}
