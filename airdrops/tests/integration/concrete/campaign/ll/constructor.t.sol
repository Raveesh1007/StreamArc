// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { StreamArcMerkleLL } from "src/StreamArcMerkleLL.sol";
import { ClaimType } from "src/types/MerkleBase.sol";

import { Integration_Test } from "./../../../Integration.t.sol";

contract Constructor_MerkleLL_Integration_Concrete_Test is Integration_Test {
    function test_Constructor() external {
        // Make Factory the caller for the constructor test.
        setMsgSender(address(factoryMerkleLL));

        // Deploy the StreamArcMerkleLL contract.
        StreamArcMerkleLL constructedLL =
            new StreamArcMerkleLL(merkleLLConstructorParams(), users.campaignCreator, address(comptroller));

        // Token allowance
        uint256 actualAllowance = dai.allowance(address(constructedLL), address(lockup));
        assertEq(actualAllowance, MAX_UINT256, "allowance");

        // StreamArcMerkleSignature
        assertEq(constructedLL.attestor(), attestor, "attestor");

        // StreamArcMerkleBase
        assertEq(constructedLL.admin(), users.campaignCreator, "admin");
        assertEq(constructedLL.CAMPAIGN_START_TIME(), CAMPAIGN_START_TIME, "campaign start time");
        assertEq(uint8(constructedLL.CLAIM_TYPE()), uint8(ClaimType.DEFAULT), "claim type");
        assertEq(constructedLL.COMPTROLLER(), address(comptroller), "comptroller");
        assertEq(constructedLL.campaignName(), CAMPAIGN_NAME, "campaign name");
        assertEq(constructedLL.EXPIRATION(), EXPIRATION, "expiration");
        assertEq(constructedLL.VESTING_GRANULARITY(), VESTING_GRANULARITY, "vesting granularity");
        assertEq(constructedLL.ipfsCID(), IPFS_CID, "IPFS CID");
        assertEq(constructedLL.IS_STREAMARC_MERKLE(), true, "is streamarc merkle");
        assertEq(constructedLL.MERKLE_ROOT(), MERKLE_ROOT, "merkleRoot");
        assertEq(constructedLL.minFeeUSD(), AIRDROP_MIN_FEE_USD, "min fee USD");
        assertEq(address(constructedLL.TOKEN()), address(dai), "token");

        // StreamArcMerkleLockup
        assertEq(address(constructedLL.STREAMARC_LOCKUP()), address(lockup), "StreamArc Lockup");
        assertEq(constructedLL.streamShape(), STREAM_SHAPE, "stream shape");
        assertEq(constructedLL.STREAM_CANCELABLE(), STREAM_CANCELABLE, "stream cancelable");
        assertEq(constructedLL.STREAM_TRANSFERABLE(), STREAM_TRANSFERABLE, "stream transferable");

        // StreamArcMerkleLL
        assertEq(constructedLL.VESTING_CLIFF_DURATION(), VESTING_CLIFF_DURATION, "vesting cliff duration");
        assertEq(
            constructedLL.VESTING_CLIFF_UNLOCK_PERCENTAGE(),
            VESTING_CLIFF_UNLOCK_PERCENTAGE,
            "vesting cliff unlock percentage"
        );
        assertEq(constructedLL.VESTING_START_TIME(), VESTING_START_TIME, "vesting start time");
        assertEq(
            constructedLL.VESTING_START_UNLOCK_PERCENTAGE(),
            VESTING_START_UNLOCK_PERCENTAGE,
            "vesting start unlock percentage"
        );
        assertEq(constructedLL.VESTING_TOTAL_DURATION(), VESTING_TOTAL_DURATION, "vesting total duration");
    }
}
