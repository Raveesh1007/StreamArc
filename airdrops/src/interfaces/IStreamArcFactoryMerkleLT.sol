// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { MerkleLT } from "../types/MerkleLT.sol";
import { IStreamArcFactoryMerkleBase } from "./IStreamArcFactoryMerkleBase.sol";
import { IStreamArcMerkleLT } from "./IStreamArcMerkleLT.sol";

/// @title IStreamArcFactoryMerkleLT
/// @notice A factory that deploys MerkleLT campaign contracts.
/// @dev See the documentation in {IStreamArcMerkleLT}.
interface IStreamArcFactoryMerkleLT is IStreamArcFactoryMerkleBase {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a {StreamArcMerkleLT} campaign is created.
    event CreateMerkleLT(
        IStreamArcMerkleLT indexed merkleLT,
        MerkleLT.ConstructorParams campaignParams,
        uint256 aggregateAmount,
        uint256 totalDuration,
        uint256 recipientCount,
        address comptroller,
        uint256 minFeeUSD
    );

    /*//////////////////////////////////////////////////////////////////////////
                                READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Verifies if the sum of percentages in `tranches` equals 100%, i.e., 1e18.
    /// @dev This is a helper function for the frontend. It is not used anywhere in the contracts.
    /// @param tranches The tranches with their respective unlock percentages.
    /// @return result True if the sum of percentages equals 100%, otherwise false.
    function isPercentagesSum100(MerkleLT.TrancheWithPercentage[] calldata tranches) external pure returns (bool result);

    /// @notice Computes the deterministic address where {StreamArcMerkleLT} campaign will be deployed.
    /// @dev Reverts if the requirements from {createMerkleLT} are not met.
    function computeMerkleLT(
        address campaignCreator,
        MerkleLT.ConstructorParams calldata campaignParams
    )
        external
        view
        returns (address merkleLT);

    /*//////////////////////////////////////////////////////////////////////////
                              STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates a new Merkle Lockup campaign with a Lockup Tranched distribution.
    ///
    /// @dev Emits a {CreateMerkleLT} event.
    ///
    /// Notes:
    /// - The contract is created with CREATE2.
    /// - The campaign's fee will be set to the min USD fee unless a custom fee is set for `msg.sender`.
    /// - A value of zero for `campaignParams.expiration` means the campaign does not expire.
    ///
    /// Requirements:
    /// - `campaignParams.token` must not be the forbidden native token.
    /// - The sum of percentages of the tranches must equal 100%.
    ///
    /// @param campaignParams Struct encapsulating the {StreamArcMerkleLT} parameters.
    /// @param aggregateAmount The total amount of ERC-20 tokens to be distributed to all recipients.
    /// @param recipientCount The total number of recipient addresses eligible for the airdrop.
    /// @return merkleLT The address of the newly created Merkle Lockup contract.
    function createMerkleLT(
        MerkleLT.ConstructorParams calldata campaignParams,
        uint256 aggregateAmount,
        uint256 recipientCount
    )
        external
        returns (IStreamArcMerkleLT merkleLT);
}
