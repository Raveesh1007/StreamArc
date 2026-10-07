// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { ERC1271WalletMock } from "@streamarc/evm-utils/src/mocks/ERC1271WalletMock.sol";

import { IStreamArcMerkleLT } from "src/interfaces/IStreamArcMerkleLT.sol";
import { IStreamArcMerkleSignature } from "src/interfaces/IStreamArcMerkleSignature.sol";

import {
    ClaimViaAttestation_Integration_Concrete_Test
} from "./../../shared/claim-via-attestation/claimViaAttestation.t.sol";
import { MerkleLT_Integration_Shared_Test } from "./../MerkleLT.t.sol";

contract ClaimViaAttestation_MerkleLT_Integration_Concrete_Test is
    ClaimViaAttestation_Integration_Concrete_Test,
    MerkleLT_Integration_Shared_Test
{
    function setUp()
        public
        virtual
        override(MerkleLT_Integration_Shared_Test, ClaimViaAttestation_Integration_Concrete_Test)
    {
        MerkleLT_Integration_Shared_Test.setUp();
        ClaimViaAttestation_Integration_Concrete_Test.setUp();
    }

    function test_WhenAttestationValid()
        external
        override
        givenAttestClaimType
        whenToAddressNotZero
        givenAttestorNotZero
        whenAttestationNotExpired
        givenAttestorIsEOA
    {
        _test_ClaimViaAttestation();
    }

    function test_WhenAttestorImplementsIERC1271Interface()
        external
        override
        givenAttestClaimType
        whenToAddressNotZero
        givenAttestorNotZero
        whenAttestationNotExpired
        givenAttestorIsContract
    {
        // Deploy an ERC1271 wallet with the EOA attestor as the admin.
        address smartAttestor = address(new ERC1271WalletMock(attestor));

        // Set the attestor to the smart contract.
        setMsgSender(users.campaignCreator);
        IStreamArcMerkleSignature(address(merkleBaseAttest)).setAttestor(smartAttestor);
        setMsgSender(users.recipient);

        _test_ClaimViaAttestation();
    }

    function _test_ClaimViaAttestation() internal {
        uint256 expectedStreamId = lockup.nextStreamId();
        uint256 previousFeeAccrued = address(comptroller).balance;
        uint256 index = getIndexInMerkleTree();

        vm.expectEmit({ emitter: address(merkleBaseAttest) });
        emit IStreamArcMerkleLT.ClaimLTWithVesting(
            index,
            users.recipient,
            CLAIM_AMOUNT,
            expectedStreamId,
            users.eve,
            false
        );

        expectCallToTransferFrom({ from: address(merkleBaseAttest), to: address(lockup), value: CLAIM_AMOUNT });
        claimViaAttestation();

        assertTrue(IStreamArcMerkleLT(address(merkleBaseAttest)).hasClaimed(index), "not claimed");
        assertEq(address(comptroller).balance, previousFeeAccrued + AIRDROP_MIN_FEE_WEI, "fee collected");
    }
}
