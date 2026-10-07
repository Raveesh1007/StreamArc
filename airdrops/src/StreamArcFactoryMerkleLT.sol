// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.22;

import { uUNIT } from "@prb/math/src/UD2x18.sol";
import { IStreamArcComptroller } from "@streamarc/evm-utils/src/interfaces/IStreamArcComptroller.sol";

import { StreamArcFactoryMerkleBase } from "./abstracts/StreamArcFactoryMerkleBase.sol";
import { IStreamArcFactoryMerkleLT } from "./interfaces/IStreamArcFactoryMerkleLT.sol";
import { IStreamArcMerkleLT } from "./interfaces/IStreamArcMerkleLT.sol";
import { Errors } from "./libraries/Errors.sol";
import { StreamArcMerkleLT } from "./StreamArcMerkleLT.sol";
import { MerkleLT } from "./types/MerkleLT.sol";

/*

███████╗ █████╗ ██████╗ ██╗     ██╗███████╗██████╗     ███████╗ █████╗  ██████╗████████╗ ██████╗ ██████╗ ██╗   ██╗
██╔════╝██╔══██╗██╔══██╗██║     ██║██╔════╝██╔══██╗    ██╔════╝██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗╚██╗ ██╔╝
███████╗███████║██████╔╝██║     ██║█████╗  ██████╔╝    █████╗  ███████║██║        ██║   ██║   ██║██████╔╝ ╚████╔╝
╚════██║██╔══██║██╔══██╗██║     ██║██╔══╝  ██╔══██╗    ██╔══╝  ██╔══██║██║        ██║   ██║   ██║██╔══██╗  ╚██╔╝
███████║██║  ██║██████╔╝███████╗██║███████╗██║  ██║    ██║     ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║   ██║
╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝╚══════╝╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝

███╗   ███╗███████╗██████╗ ██╗  ██╗██╗     ███████╗    ██╗     ████████╗
████╗ ████║██╔════╝██╔══██╗██║ ██╔╝██║     ██╔════╝    ██║     ╚══██╔══╝
██╔████╔██║█████╗  ██████╔╝█████╔╝ ██║     █████╗      ██║        ██║
██║╚██╔╝██║██╔══╝  ██╔══██╗██╔═██╗ ██║     ██╔══╝      ██║        ██║
██║ ╚═╝ ██║███████╗██║  ██║██║  ██╗███████╗███████╗    ███████╗   ██║
╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝    ╚══════╝   ╚═╝

*/

/// @title StreamArcFactoryMerkleLT
/// @notice See the documentation in {IStreamArcFactoryMerkleLT}.
contract StreamArcFactoryMerkleLT is IStreamArcFactoryMerkleLT, StreamArcFactoryMerkleBase {
    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @param initialComptroller The address of the initial comptroller contract.
    constructor(address initialComptroller) StreamArcFactoryMerkleBase(initialComptroller) { }

    /*//////////////////////////////////////////////////////////////////////////
                          USER-FACING READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamArcFactoryMerkleLT
    function computeMerkleLT(
        address campaignCreator,
        MerkleLT.ConstructorParams calldata campaignParams
    )
        external
        view
        override
        returns (address merkleLT)
    {
        // Calculate the total percentage.
        (, uint64 totalPercentage) = _calculateTrancheTotals(campaignParams.tranchesWithPercentages);

        // Check: validate the user-provided token and the total percentage.
        _checkDeploymentParams(address(campaignParams.token), totalPercentage);

        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(abi.encodePacked(campaignCreator, comptroller, abi.encode(campaignParams)));

        // Get the bytecode hash for the {StreamArcMerkleLT} contract.
        bytes32 bytecodeHash = keccak256(
            abi.encodePacked(
                type(StreamArcMerkleLT).creationCode, abi.encode(campaignParams, campaignCreator, address(comptroller))
            )
        );

        // Compute CREATE2 address using `keccak256(0xff + deployer + salt + bytecodeHash)`.
        merkleLT =
            address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, bytecodeHash)))));
    }

    /// @inheritdoc IStreamArcFactoryMerkleLT
    function isPercentagesSum100(MerkleLT.TrancheWithPercentage[] calldata tranches)
        external
        pure
        override
        returns (bool result)
    {
        // Calculate the total percentage.
        (, uint64 totalPercentage) = _calculateTrancheTotals(tranches);

        // Return true if the sum of percentages equals 100%.
        return totalPercentage == uUNIT;
    }

    /*//////////////////////////////////////////////////////////////////////////
                        USER-FACING STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamArcFactoryMerkleLT
    function createMerkleLT(
        MerkleLT.ConstructorParams calldata campaignParams,
        uint256 aggregateAmount,
        uint256 recipientCount
    )
        external
        override
        returns (IStreamArcMerkleLT merkleLT)
    {
        // Calculate the total percentage.
        (uint256 totalDuration, uint64 totalPercentage) =
            _calculateTrancheTotals(campaignParams.tranchesWithPercentages);

        // Check: validate the user-provided token and the total percentage.
        _checkDeploymentParams(address(campaignParams.token), totalPercentage);

        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, comptroller, abi.encode(campaignParams)));

        // Deploy the MerkleLT contract with CREATE2.
        merkleLT = new StreamArcMerkleLT{ salt: salt }({
            campaignParams: campaignParams,
            campaignCreator: msg.sender,
            comptroller: address(comptroller)
        });

        // Log the creation of the MerkleLT contract, including some metadata that is not stored on-chain.
        emit CreateMerkleLT({
            merkleLT: merkleLT,
            campaignParams: campaignParams,
            aggregateAmount: aggregateAmount,
            totalDuration: totalDuration,
            recipientCount: recipientCount,
            comptroller: address(comptroller),
            minFeeUSD: comptroller.getMinFeeUSDFor({
                protocol: IStreamArcComptroller.Protocol.Airdrops,
                user: msg.sender
            })
        });
    }

    /*//////////////////////////////////////////////////////////////////////////
                            PRIVATE READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Calculate the total duration and total percentage of the tranches.
    function _calculateTrancheTotals(MerkleLT.TrancheWithPercentage[] memory tranches)
        private
        pure
        returns (uint256 totalDuration, uint64 totalPercentage)
    {
        uint256 count = tranches.length;
        for (uint256 i = 0; i < count; ++i) {
            totalPercentage += tranches[i].unlockPercentage.unwrap();

            // Safe to use `unchecked` for total duration because its only used in the event.
            unchecked {
                totalDuration += tranches[i].duration;
            }
        }
    }

    /// @dev Validate the token and the total percentage.
    function _checkDeploymentParams(address token, uint64 totalPercentage) private view {
        // Check: token is not the native token.
        _forbidNativeToken(token);

        // Check: the sum of percentages equals 100%.
        if (totalPercentage != uUNIT) {
            revert Errors.StreamArcFactoryMerkleLT_TotalPercentageNotOneHundred(totalPercentage);
        }
    }
}
