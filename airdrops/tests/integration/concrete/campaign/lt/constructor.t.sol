// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { StreamArcMerkleLT } from "src/StreamArcMerkleLT.sol";
import { ClaimType } from "src/types/MerkleBase.sol";
import { MerkleLT } from "src/types/MerkleLT.sol";

import { Integration_Test } from "./../../../Integration.t.sol";

contract Constructor_MerkleLT_Integration_Concrete_Test is Integration_Test {
    function test_Constructor() external {
        // Make Factory the caller for the constructor test.
        setMsgSender(address(factoryMerkleLT));

        // Deploy the StreamArcMerkleLT contract.
        MerkleLT.ConstructorParams memory params = merkleLTConstructorParams();

        StreamArcMerkleLT constructedLT = new StreamArcMerkleLT(params, users.campaignCreator, address(comptroller));

        // Token allowance
        uint256 actualAllowance = dai.allowance(address(constructedLT), address(lockup));
        assertEq(actualAllowance, MAX_UINT256, "allowance");

        // StreamArcMerkleSignature
        assertEq(constructedLT.attestor(), attestor, "attestor");

        // StreamArcMerkleBase
        assertEq(constructedLT.admin(), users.campaignCreator, "admin");
        assertEq(constructedLT.campaignName(), CAMPAIGN_NAME, "campaign name");
        assertEq(constructedLT.CAMPAIGN_START_TIME(), CAMPAIGN_START_TIME, "campaign start time");
        assertEq(uint8(constructedLT.CLAIM_TYPE()), uint8(ClaimType.DEFAULT), "claim type");
        assertEq(constructedLT.COMPTROLLER(), address(comptroller), "comptroller");

        assertEq(constructedLT.EXPIRATION(), EXPIRATION, "expiration");
        assertEq(constructedLT.ipfsCID(), IPFS_CID, "IPFS CID");
        assertEq(constructedLT.IS_STREAMARC_MERKLE(), true, "is streamarc merkle");
        assertEq(constructedLT.MERKLE_ROOT(), MERKLE_ROOT, "Merkle root");
        assertEq(constructedLT.minFeeUSD(), AIRDROP_MIN_FEE_USD, "min fee USD");
        assertEq(address(constructedLT.TOKEN()), address(dai), "token");

        // StreamArcMerkleLockup
        assertEq(address(constructedLT.STREAMARC_LOCKUP()), address(lockup), "StreamArc Lockup");
        assertEq(constructedLT.streamShape(), STREAM_SHAPE, "stream shape");
        assertEq(constructedLT.STREAM_CANCELABLE(), STREAM_CANCELABLE, "stream cancelable");
        assertEq(constructedLT.STREAM_TRANSFERABLE(), STREAM_TRANSFERABLE, "stream transferable");

        // StreamArcMerkleLT
        assertEq(constructedLT.VESTING_START_TIME(), VESTING_START_TIME, "vesting start time");
        assertEq(constructedLT.tranchesWithPercentages(), params.tranchesWithPercentages);
    }
}
