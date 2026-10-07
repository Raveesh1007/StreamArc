// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { StreamArcMerkleInstant } from "src/StreamArcMerkleInstant.sol";
import { ClaimType } from "src/types/MerkleBase.sol";

import { Integration_Test } from "./../../../Integration.t.sol";

contract Constructor_MerkleInstant_Integration_Concrete_Test is Integration_Test {
    function test_Constructor() external {
        // Make Factory the caller for the constructor test.
        setMsgSender(address(factoryMerkleInstant));

        // Deploy the StreamArcMerkleInstant contract.
        StreamArcMerkleInstant constructedInstant =
            new StreamArcMerkleInstant(merkleInstantConstructorParams(), users.campaignCreator, address(comptroller));

        // StreamArcMerkleSignature
        assertEq(constructedInstant.attestor(), attestor, "attestor");

        // StreamArcMerkleBase
        assertEq(constructedInstant.admin(), users.campaignCreator, "admin");
        assertEq(constructedInstant.campaignName(), CAMPAIGN_NAME, "campaign name");
        assertEq(constructedInstant.CAMPAIGN_START_TIME(), CAMPAIGN_START_TIME, "campaign start time");
        assertEq(uint8(constructedInstant.CLAIM_TYPE()), uint8(ClaimType.DEFAULT), "claim type");
        assertEq(constructedInstant.COMPTROLLER(), address(comptroller), "comptroller");
        assertEq(constructedInstant.EXPIRATION(), EXPIRATION, "expiration");
        assertEq(constructedInstant.ipfsCID(), IPFS_CID, "IPFS CID");
        assertEq(constructedInstant.IS_STREAMARC_MERKLE(), true, "is streamarc merkle");
        assertEq(constructedInstant.MERKLE_ROOT(), MERKLE_ROOT, "merkleRoot");
        assertEq(constructedInstant.minFeeUSD(), AIRDROP_MIN_FEE_USD, "min fee USD");
        assertEq(address(constructedInstant.TOKEN()), address(dai), "token");
    }
}
