// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.8.22;

import { Comptrollerable } from "@streamarc/evm-utils/src/Comptrollerable.sol";

import { IStreamArcFactoryMerkleBase } from "./../interfaces/IStreamArcFactoryMerkleBase.sol";
import { Errors } from "./../libraries/Errors.sol";

/// @title StreamArcFactoryMerkleBase
/// @notice See the documentation in {IStreamArcFactoryMerkleBase}.
abstract contract StreamArcFactoryMerkleBase is
    Comptrollerable, // 1 inherited component
    IStreamArcFactoryMerkleBase // 1 inherited component
{
    /*//////////////////////////////////////////////////////////////////////////
                                  STATE VARIABLES
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamArcFactoryMerkleBase
    address public override nativeToken;

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    /// @param initialComptroller The address of the initial comptroller contract.
    constructor(address initialComptroller) Comptrollerable(initialComptroller) { }

    /*//////////////////////////////////////////////////////////////////////////
                        USER-FACING STATE-CHANGING FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc IStreamArcFactoryMerkleBase
    function setNativeToken(address newNativeToken) external override onlyComptroller {
        // Check: provided token is not zero address.
        if (newNativeToken == address(0)) {
            revert Errors.StreamArcFactoryMerkleBase_NativeTokenZeroAddress();
        }

        // Check: native token is not set.
        if (nativeToken != address(0)) {
            revert Errors.StreamArcFactoryMerkleBase_NativeTokenAlreadySet(nativeToken);
        }

        // Effect: set the native token.
        nativeToken = newNativeToken;

        // Log the update.
        emit SetNativeToken({ comptroller: msg.sender, nativeToken: newNativeToken });
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL READ-ONLY FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Checks that the provided token is not the native token.
    /// @dev Reverts if the provided token is the native token.
    function _forbidNativeToken(address token) internal view {
        if (token == nativeToken) {
            revert Errors.StreamArcFactoryMerkleBase_ForbidNativeToken(token);
        }
    }
}
