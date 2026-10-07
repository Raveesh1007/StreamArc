// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IStreamArcLockup } from "@streamarc/lockup/src/interfaces/IStreamArcLockup.sol";
import { StreamArcMerkleLT } from "src/StreamArcMerkleLT.sol";
import { MerkleLT } from "src/types/MerkleLT.sol";
import { LeafData } from "../../utils/MerkleBuilder.sol";
import { Store } from "../stores/Store.sol";
import { BaseHandler } from "./BaseHandler.sol";

/// @notice Handler for the Merkle LT campaign.
contract MerkleLTHandler is BaseHandler {
    /*//////////////////////////////////////////////////////////////////////////
                                     VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    IStreamArcLockup public lockup;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(address comptroller_, address lockup_, Store store_) BaseHandler(comptroller_, store_) {
        lockup = IStreamArcLockup(lockup_);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     OVERRIDES
    //////////////////////////////////////////////////////////////////////////*/

    function _claim(LeafData memory leafData, bytes32[] memory merkleProof) internal override {
        StreamArcMerkleLT merkleLT = StreamArcMerkleLT(address(campaign));

        // Claim the airdrop.
        merkleLT.claim{ value: AIRDROP_MIN_FEE_WEI }(leafData.index, leafData.recipient, leafData.amount, merkleProof);

        // Update claim amount in store.
        store.updateTotalClaimAmount(address(campaign), leafData.amount);
    }

    function _deployCampaign(address campaignCreator, bytes32 merkleRoot) internal override returns (address) {
        // Fuzz the tranches with percentages.
        MerkleLT.TrancheWithPercentage[] memory tranchesWithPercentages_ = new MerkleLT.TrancheWithPercentage[](2);
        fuzzTranchesMerkleLT({ vestingStartTime: 0, tranches: tranchesWithPercentages_ });

        // Prepare constructor parameters.
        MerkleLT.ConstructorParams memory params;

        params.campaignName = CAMPAIGN_NAME;
        params.campaignStartTime = getBlockTimestamp();
        params.cancelable = STREAM_CANCELABLE;
        params.expiration = getBlockTimestamp() + 365 days;
        params.initialAdmin = campaignCreator;
        params.ipfsCID = IPFS_CID;
        params.lockup = lockup;
        params.merkleRoot = merkleRoot;
        params.shape = STREAM_SHAPE;
        params.token = campaignToken;
        params.tranchesWithPercentages = tranchesWithPercentages_;
        params.transferable = STREAM_TRANSFERABLE;
        params.vestingStartTime = 0; // Use block.timestamp as sentinel value

        // Deploy and return the campaign address.
        return address(new StreamArcMerkleLT(params, campaignCreator, comptroller));
    }
}
