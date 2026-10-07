// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IComptrollerable } from "@streamarc/evm-utils/src/interfaces/IComptrollerable.sol";
import { IStreamArcComptroller } from "@streamarc/evm-utils/src/interfaces/IStreamArcComptroller.sol";
import { StreamArcLockup } from "src/StreamArcLockup.sol";

import { Integration_Test } from "../Integration.t.sol";

contract Constructor_Integration_Concrete_Test is Integration_Test {
    function test_Constructor() external {
        // Expect the relevant event to be emitted.
        vm.expectEmit();
        emit IComptrollerable.SetComptroller({
            newComptroller: comptroller,
            oldComptroller: IStreamArcComptroller(address(0))
        });

        // Construct the contract.
        StreamArcLockup constructedLockup = new StreamArcLockup({
            initialComptroller: address(comptroller),
            initialNFTDescriptor: address(nftDescriptor)
        });

        // {Comptrollerable.constructor}
        address actualComptroller = address(constructedLockup.comptroller());
        address expectedComptroller = address(comptroller);
        assertEq(actualComptroller, expectedComptroller, "comptroller");

        // {StreamArcLockupState.constructor}
        uint256 actualStreamId = constructedLockup.nextStreamId();
        uint256 expectedStreamId = 1;
        assertEq(actualStreamId, expectedStreamId, "nextStreamId");

        // {StreamArcLockupState.constructor}
        address actualNFTDescriptor = address(constructedLockup.nftDescriptor());
        address expectedNFTDescriptor = address(nftDescriptor);
        assertEq(actualNFTDescriptor, expectedNFTDescriptor, "nftDescriptor");

        // {StreamArcLockup.supportsInterface}
        assertTrue(constructedLockup.supportsInterface(0x49064906), "ERC-4906 interface ID");
    }
}
