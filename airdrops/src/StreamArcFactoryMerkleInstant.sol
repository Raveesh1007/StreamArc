// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.22;

import { IStreamArcComptroller } from "@streamarc/evm-utils/src/interfaces/IStreamArcComptroller.sol";
import { StreamArcFactoryMerkleBase } from "./abstracts/StreamArcFactoryMerkleBase.sol";
import { IStreamArcFactoryMerkleInstant } from "./interfaces/IStreamArcFactoryMerkleInstant.sol";
import { IStreamArcMerkleInstant } from "./interfaces/IStreamArcMerkleInstant.sol";
import { StreamArcMerkleInstant } from "./StreamArcMerkleInstant.sol";
import { MerkleInstant } from "./types/MerkleInstant.sol";

/*

███████╗ █████╗ ██████╗ ██╗     ██╗███████╗██████╗     ███████╗ █████╗  ██████╗████████╗ ██████╗ ██████╗ ██╗   ██╗
██╔════╝██╔══██╗██╔══██╗██║     ██║██╔════╝██╔══██╗    ██╔════╝██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗╚██╗ ██╔╝
███████╗███████║██████╔╝██║     ██║█████╗  ██████╔╝    █████╗  ███████║██║        ██║   ██║   ██║██████╔╝ ╚████╔╝
╚════██║██╔══██║██╔══██╗██║     ██║██╔══╝  ██╔══██╗    ██╔══╝  ██╔══██║██║        ██║   ██║   ██║██╔══██╗  ╚██╔╝
███████║██║  ██║██████╔╝███████╗██║███████╗██║  ██║    ██║     ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║   ██║
╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝╚══════╝╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝

███╗   ███╗███████╗██████╗ ██╗  ██╗██╗     ███████╗    ██╗███╗   ██╗███████╗████████╗ █████╗ ███╗   ██╗████████╗
████╗ ████║██╔════╝██╔══██╗██║ ██╔╝██║     ██╔════╝    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗████╗  ██║╚══██╔══╝
██╔████╔██║█████╗  ██████╔╝█████╔╝ ██║     █████╗      ██║██╔██╗ ██║███████╗   ██║   ███████║██╔██╗ ██║   ██║
██║╚██╔╝██║██╔══╝  ██╔══██╗██╔═██╗ ██║     ██╔══╝      ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║╚██╗██║   ██║
██║ ╚═╝ ██║███████╗██║  ██║██║  ██╗███████╗███████╗    ██║██║ ╚████║███████║   ██║   ██║  ██║██║ ╚████║   ██║
╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝

*/

/// @title StreamArcFactoryMerkleInstant
/// @notice See the documentation in {IStreamArcFactoryMerkleInstant}.
contract StreamArcFactoryMerkleInstant is IStreamArcFactoryMerkleInstant, StreamArcFactoryMerkleBase {
    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @param initialComptroller The address of the initial comptroller contract.
    constructor(address initialComptroller) StreamArcFactoryMerkleBase(initialComptroller) { }

    /*//////////////////////////////////////////////////////////////////////////
                          USER-FACING READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamArcFactoryMerkleInstant
    function computeMerkleInstant(
        address campaignCreator,
        MerkleInstant.ConstructorParams calldata campaignParams
    )
        external
        view
        override
        returns (address merkleInstant)
    {
        // Check: user-provided token is not the native token.
        _forbidNativeToken(address(campaignParams.token));

        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(abi.encodePacked(campaignCreator, comptroller, abi.encode(campaignParams)));

        // Get the bytecode hash for the {StreamArcMerkleInstant} contract.
        bytes32 bytecodeHash = keccak256(
            abi.encodePacked(
                type(StreamArcMerkleInstant).creationCode,
                abi.encode(campaignParams, campaignCreator, address(comptroller))
            )
        );

        // Compute CREATE2 address using `keccak256(0xff + deployer + salt + bytecodeHash)`.
        merkleInstant =
            address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, bytecodeHash)))));
    }

    /*//////////////////////////////////////////////////////////////////////////
                        USER-FACING STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamArcFactoryMerkleInstant
    function createMerkleInstant(
        MerkleInstant.ConstructorParams calldata campaignParams,
        uint256 aggregateAmount,
        uint256 recipientCount
    )
        external
        override
        returns (IStreamArcMerkleInstant merkleInstant)
    {
        // Check: user-provided token is not the native token.
        _forbidNativeToken(address(campaignParams.token));

        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, comptroller, abi.encode(campaignParams)));

        // Deploy the MerkleInstant contract with CREATE2.
        merkleInstant = new StreamArcMerkleInstant{ salt: salt }({
            campaignParams: campaignParams,
            campaignCreator: msg.sender,
            comptroller: address(comptroller)
        });

        // Log the creation of the MerkleInstant contract, including some metadata that is not stored on-chain.
        emit CreateMerkleInstant({
            merkleInstant: merkleInstant,
            campaignParams: campaignParams,
            aggregateAmount: aggregateAmount,
            recipientCount: recipientCount,
            comptroller: address(comptroller),
            minFeeUSD: comptroller.getMinFeeUSDFor({
                protocol: IStreamArcComptroller.Protocol.Airdrops,
                user: msg.sender
            })
        });
    }
}
