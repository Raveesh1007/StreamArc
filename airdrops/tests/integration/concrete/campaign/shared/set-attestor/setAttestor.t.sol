// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IStreamArcMerkleSignature } from "src/interfaces/IStreamArcMerkleSignature.sol";
import { Errors } from "src/libraries/Errors.sol";

import { Integration_Test } from "../../../../Integration.t.sol";

abstract contract SetAttestor_Integration_Concrete_Test is Integration_Test {
    address internal newAttestor = makeAddr("newAttestor");

    function test_RevertWhen_CallerNotComptroller() external whenCallerNotCampaignCreator {
        setMsgSender(users.eve);

        // It should revert.
        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.StreamArcMerkleSignature_CallerNotAuthorized.selector,
                users.eve,
                users.campaignCreator,
                address(comptroller)
            )
        );
        IStreamArcMerkleSignature(address(merkleBase)).setAttestor(newAttestor);
    }

    function test_WhenCallerComptroller() external whenCallerNotCampaignCreator {
        setMsgSender(address(comptroller));

        // It should emit a {SetAttestor} event.
        vm.expectEmit({ emitter: address(merkleBase) });
        emit IStreamArcMerkleSignature.SetAttestor({
            caller: address(comptroller),
            previousAttestor: attestor,
            newAttestor: newAttestor
        });

        IStreamArcMerkleSignature(address(merkleBase)).setAttestor(newAttestor);

        // It should set the attestor.
        assertEq(IStreamArcMerkleSignature(address(merkleBase)).attestor(), newAttestor, "attestor");
    }

    function test_WhenCallerCampaignCreator() external {
        // It should emit a {SetAttestor} event.
        vm.expectEmit({ emitter: address(merkleBase) });
        emit IStreamArcMerkleSignature.SetAttestor({
            caller: users.campaignCreator,
            previousAttestor: attestor,
            newAttestor: newAttestor
        });

        IStreamArcMerkleSignature(address(merkleBase)).setAttestor(newAttestor);

        // It should set the attestor.
        assertEq(IStreamArcMerkleSignature(address(merkleBase)).attestor(), newAttestor, "attestor");
    }
}
