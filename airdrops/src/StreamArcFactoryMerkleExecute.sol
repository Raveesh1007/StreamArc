// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.22;

import { IStreamArcComptroller } from "@streamarc/evm-utils/src/interfaces/IStreamArcComptroller.sol";

import { StreamArcFactoryMerkleBase } from "./abstracts/StreamArcFactoryMerkleBase.sol";
import { IStreamArcFactoryMerkleExecute } from "./interfaces/IStreamArcFactoryMerkleExecute.sol";
import { IStreamArcMerkleExecute } from "./interfaces/IStreamArcMerkleExecute.sol";
import { Errors } from "./libraries/Errors.sol";
import { StreamArcMerkleExecute } from "./StreamArcMerkleExecute.sol";
import { MerkleExecute } from "./types/MerkleExecute.sol";

/*

███████╗ █████╗ ██████╗ ██╗     ██╗███████╗██████╗     ███████╗ █████╗  ██████╗████████╗ ██████╗ ██████╗ ██╗   ██╗
██╔════╝██╔══██╗██╔══██╗██║     ██║██╔════╝██╔══██╗    ██╔════╝██╔══██╗██╔════╝╚══██╔══╝██╔═══██╗██╔══██╗╚██╗ ██╔╝
███████╗███████║██████╔╝██║     ██║█████╗  ██████╔╝    █████╗  ███████║██║        ██║   ██║   ██║██████╔╝ ╚████╔╝
╚════██║██╔══██║██╔══██╗██║     ██║██╔══╝  ██╔══██╗    ██╔══╝  ██╔══██║██║        ██║   ██║   ██║██╔══██╗  ╚██╔╝
███████║██║  ██║██████╔╝███████╗██║███████╗██║  ██║    ██║     ██║  ██║╚██████╗   ██║   ╚██████╔╝██║  ██║   ██║
╚══════╝╚═╝  ╚═╝╚═════╝ ╚══════╝╚═╝╚══════╝╚═╝  ╚═╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝

███╗   ███╗███████╗██████╗ ██╗  ██╗██╗     ███████╗    ███████╗██╗  ██╗███████╗ ██████╗██╗   ██╗████████╗███████╗
████╗ ████║██╔════╝██╔══██╗██║ ██╔╝██║     ██╔════╝    ██╔════╝╚██╗██╔╝██╔════╝██╔════╝██║   ██║╚══██╔══╝██╔════╝
██╔████╔██║█████╗  ██████╔╝█████╔╝ ██║     █████╗      █████╗   ╚███╔╝ █████╗  ██║     ██║   ██║   ██║   █████╗
██║╚██╔╝██║██╔══╝  ██╔══██╗██╔═██╗ ██║     ██╔══╝      ██╔══╝   ██╔██╗ ██╔══╝  ██║     ██║   ██║   ██║   ██╔══╝
██║ ╚═╝ ██║███████╗██║  ██║██║  ██╗███████╗███████╗    ███████╗██╔╝ ██╗███████╗╚██████╗╚██████╔╝   ██║   ███████╗
╚═╝     ╚═╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚══════╝    ╚══════╝╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═════╝    ╚═╝   ╚══════╝

*/

/// @title StreamArcFactoryMerkleExecute
/// @notice See the documentation in {IStreamArcFactoryMerkleExecute}.
contract StreamArcFactoryMerkleExecute is IStreamArcFactoryMerkleExecute, StreamArcFactoryMerkleBase {
    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @param initialComptroller The address of the initial comptroller contract.
    constructor(address initialComptroller) StreamArcFactoryMerkleBase(initialComptroller) { }

    /*//////////////////////////////////////////////////////////////////////////
                          USER-FACING READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamArcFactoryMerkleExecute
    function computeMerkleExecute(
        address campaignCreator,
        MerkleExecute.ConstructorParams calldata campaignParams
    )
        external
        view
        override
        returns (address merkleExecute)
    {
        // Check: validate the deployment parameters.
        _checkDeploymentParams(address(campaignParams.token), campaignParams.target);

        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(abi.encodePacked(campaignCreator, comptroller, abi.encode(campaignParams)));

        // Get the bytecode hash for the {StreamArcMerkleExecute} contract.
        bytes32 bytecodeHash = keccak256(
            abi.encodePacked(
                type(StreamArcMerkleExecute).creationCode,
                abi.encode(campaignParams, campaignCreator, address(comptroller))
            )
        );

        // Compute CREATE2 address using `keccak256(0xff + deployer + salt + bytecodeHash)`.
        merkleExecute =
            address(uint160(uint256(keccak256(abi.encodePacked(bytes1(0xff), address(this), salt, bytecodeHash)))));
    }

    /*//////////////////////////////////////////////////////////////////////////
                        USER-FACING STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamArcFactoryMerkleExecute
    function createMerkleExecute(
        MerkleExecute.ConstructorParams calldata campaignParams,
        uint256 aggregateAmount,
        uint256 recipientCount
    )
        external
        override
        returns (IStreamArcMerkleExecute merkleExecute)
    {
        // Check: validate the deployment parameters.
        _checkDeploymentParams(address(campaignParams.token), campaignParams.target);

        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(abi.encodePacked(msg.sender, comptroller, abi.encode(campaignParams)));

        // Deploy the MerkleExecute contract with CREATE2.
        merkleExecute = new StreamArcMerkleExecute{ salt: salt }({
            campaignParams: campaignParams,
            campaignCreator: msg.sender,
            comptroller: address(comptroller)
        });

        // Log the creation of the MerkleExecute contract, including some metadata that is not stored on-chain.
        emit CreateMerkleExecute({
            merkleExecute: merkleExecute,
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

    /*//////////////////////////////////////////////////////////////////////////
                                  PRIVATE FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Validates the deployment parameters.
    function _checkDeploymentParams(address token, address target) private view {
        // Check: user-provided token is not the native token.
        _forbidNativeToken(token);

        // Check: target is a contract.
        if (target.code.length == 0) {
            revert Errors.StreamArcFactoryMerkleExecute_TargetNotContract(target);
        }
    }
}
