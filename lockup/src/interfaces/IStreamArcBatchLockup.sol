// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import { BatchLockup } from "../types/BatchLockup.sol";
import { IStreamArcLockup } from "./IStreamArcLockup.sol";

/// @title IStreamArcBatchLockup
/// @notice Helper to batch create Lockup streams.
interface IStreamArcBatchLockup {
    /*//////////////////////////////////////////////////////////////////////////
                                       EVENTS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a batch of Lockup streams are created.
    /// @param funder The address funding the streams.
    /// @param lockup The address of the {StreamArcLockup} contract used to create the streams.
    /// @param streamIds The ids of the newly created streams, the ones that were successfully created.
    event CreateLockupBatch(address indexed funder, IStreamArcLockup indexed lockup, uint256[] streamIds);

    /*//////////////////////////////////////////////////////////////////////////
                        USER-FACING STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Creates a batch of LD streams using `createWithDurationsLD`.
    ///
    /// @dev Requirements:
    /// - There must be at least one element in `batch`.
    /// - All requirements from {IStreamArcLockupDynamic.createWithDurationsLD} must be met for each stream.
    ///
    /// @param lockup The address of the {StreamArcLockup} contract.
    /// @param token The contract address of the ERC-20 token to be distributed.
    /// @param batch An array of structs, each encapsulating a subset of the parameters of
    /// {IStreamArcLockupDynamic.createWithDurationsLD}.
    /// @return streamIds The ids of the newly created streams.
    function createWithDurationsLD(
        IStreamArcLockup lockup,
        IERC20 token,
        BatchLockup.CreateWithDurationsLD[] calldata batch
    )
        external
        returns (uint256[] memory streamIds);

    /// @notice Creates a batch of LD streams using `createWithTimestampsLD`.
    ///
    /// @dev Requirements:
    /// - There must be at least one element in `batch`.
    /// - All requirements from {IStreamArcLockupDynamic.createWithTimestampsLD} must be met for each stream.
    ///
    /// @param lockup The address of the {StreamArcLockup} contract.
    /// @param token The contract address of the ERC-20 token to be distributed.
    /// @param batch An array of structs, each encapsulating a subset of the parameters of
    /// {IStreamArcLockupDynamic.createWithTimestampsLD}.
    /// @return streamIds The ids of the newly created streams.
    function createWithTimestampsLD(
        IStreamArcLockup lockup,
        IERC20 token,
        BatchLockup.CreateWithTimestampsLD[] calldata batch
    )
        external
        returns (uint256[] memory streamIds);

    /// @notice Creates a batch of LL streams using `createWithDurationsLL`.
    ///
    /// @dev Requirements:
    /// - There must be at least one element in `batch`.
    /// - All requirements from {IStreamArcLockupLinear.createWithDurationsLL} must be met for each stream.
    ///
    /// @param lockup The address of the {StreamArcLockup} contract.
    /// @param token The contract address of the ERC-20 token to be distributed.
    /// @param batch An array of structs, each encapsulating a subset of the parameters of
    /// {IStreamArcLockupLinear.createWithDurationsLL}.
    /// @return streamIds The ids of the newly created streams.
    function createWithDurationsLL(
        IStreamArcLockup lockup,
        IERC20 token,
        BatchLockup.CreateWithDurationsLL[] calldata batch
    )
        external
        returns (uint256[] memory streamIds);

    /// @notice Creates a batch of LL streams using `createWithTimestampsLL`.
    ///
    /// @dev Requirements:
    /// - There must be at least one element in `batch`.
    /// - All requirements from {IStreamArcLockupLinear.createWithTimestampsLL} must be met for each stream.
    ///
    /// @param lockup The address of the {StreamArcLockup} contract.
    /// @param token The contract address of the ERC-20 token to be distributed.
    /// @param batch An array of structs, each encapsulating a subset of the parameters of
    /// {IStreamArcLockupLinear.createWithTimestampsLL}.
    /// @return streamIds The ids of the newly created streams.
    function createWithTimestampsLL(
        IStreamArcLockup lockup,
        IERC20 token,
        BatchLockup.CreateWithTimestampsLL[] calldata batch
    )
        external
        returns (uint256[] memory streamIds);

    /// @notice Creates a batch of LPG streams using `createWithTimestampsLPG`.
    ///
    /// @dev Notes:
    /// - The LPG model does not support a "createWithDuration" function because the {StreamArcLockup} contract is at
    /// the size limit. If the EVM contract size limit is increased in the future, this function will be added.
    ///
    /// Requirements:
    /// - There must be at least one element in `batch`.
    /// - All requirements from {IStreamArcLockupPriceGated.createWithTimestampsLPG} must be met for each stream.
    ///
    /// @param lockup The address of the {StreamArcLockup} contract.
    /// @param token The contract address of the ERC-20 token to be distributed.
    /// @param batch An array of structs, each encapsulating a subset of the parameters of
    /// {IStreamArcLockupPriceGated.createWithTimestampsLPG}.
    /// @return streamIds The ids of the newly created streams.
    function createWithTimestampsLPG(
        IStreamArcLockup lockup,
        IERC20 token,
        BatchLockup.CreateWithTimestampsLPG[] calldata batch
    )
        external
        returns (uint256[] memory streamIds);

    /// @notice Creates a batch of LT streams using `createWithDurationsLT`.
    ///
    /// @dev Requirements:
    /// - There must be at least one element in `batch`.
    /// - All requirements from {IStreamArcLockupTranched.createWithDurationsLT} must be met for each stream.
    ///
    /// @param lockup The address of the {StreamArcLockup} contract.
    /// @param token The contract address of the ERC-20 token to be distributed.
    /// @param batch An array of structs, each encapsulating a subset of the parameters of
    /// {IStreamArcLockupTranched.createWithDurationsLT}.
    /// @return streamIds The ids of the newly created streams.
    function createWithDurationsLT(
        IStreamArcLockup lockup,
        IERC20 token,
        BatchLockup.CreateWithDurationsLT[] calldata batch
    )
        external
        returns (uint256[] memory streamIds);

    /// @notice Creates a batch of LT streams using `createWithTimestampsLT`.
    ///
    /// @dev Requirements:
    /// - There must be at least one element in `batch`.
    /// - All requirements from {IStreamArcLockupTranched.createWithTimestampsLT} must be met for each stream.
    ///
    /// @param lockup The address of the {StreamArcLockup} contract.
    /// @param token The contract address of the ERC-20 token to be distributed.
    /// @param batch An array of structs, each encapsulating a subset of the parameters of
    /// {IStreamArcLockupTranched.createWithTimestampsLT}.
    /// @return streamIds The ids of the newly created streams.
    function createWithTimestampsLT(
        IStreamArcLockup lockup,
        IERC20 token,
        BatchLockup.CreateWithTimestampsLT[] calldata batch
    )
        external
        returns (uint256[] memory streamIds);
}
