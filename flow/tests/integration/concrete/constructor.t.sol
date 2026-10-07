// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IComptrollerable } from "@streamarc/evm-utils/src/interfaces/IComptrollerable.sol";
import { IStreamArcComptroller } from "@streamarc/evm-utils/src/interfaces/IStreamArcComptroller.sol";

import { StreamArcFlow } from "src/StreamArcFlow.sol";

import { Shared_Integration_Concrete_Test } from "./Concrete.t.sol";

contract Constructor_Integration_Concrete_Test is Shared_Integration_Concrete_Test {
    function test_Constructor() external {
        // Expect the relevant event to be emitted.
        vm.expectEmit();
        emit IComptrollerable.SetComptroller({
            newComptroller: comptroller,
            oldComptroller: IStreamArcComptroller(address(0))
        });

        // Construct the contract.
        StreamArcFlow constructedFlow = new StreamArcFlow(address(comptroller), address(nftDescriptor));

        // {StreamArcFlowState.nextStreamId}
        uint256 actualStreamId = constructedFlow.nextStreamId();
        uint256 expectedStreamId = 1;
        assertEq(actualStreamId, expectedStreamId, "nextStreamId");

        // {Comptrollerable.constructor}
        address actualComptroller = address(constructedFlow.comptroller());
        assertEq(actualComptroller, address(comptroller), "comptroller");

        // {StreamArcFlowState.supportsInterface}
        assertTrue(constructedFlow.supportsInterface(0x49064906), "ERC-4906 interface ID");

        address actualNFTDescriptor = address(constructedFlow.nftDescriptor());
        assertEq(actualNFTDescriptor, address(nftDescriptor), "nftDescriptor");
    }
}
