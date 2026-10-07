// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IStreamArcFactoryMerkleBase } from "src/interfaces/IStreamArcFactoryMerkleBase.sol";
import { IStreamArcMerkleBase } from "src/interfaces/IStreamArcMerkleBase.sol";
import { Integration_Test } from "./../../../Integration.t.sol";

import { SetNativeToken_Integration_Concrete_Test } from "../shared/set-native-token/setNativeToken.t.sol";

/*//////////////////////////////////////////////////////////////////////////
                             NON-SHARED TESTS
//////////////////////////////////////////////////////////////////////////*/

abstract contract FactoryMerkleInstant_Integration_Shared_Test is Integration_Test {
    function setUp() public virtual override {
        Integration_Test.setUp();

        // Cast the {FactoryMerkleInstant} contract as {IStreamArcFactoryMerkleBase}
        factoryMerkleBase = IStreamArcFactoryMerkleBase(factoryMerkleInstant);

        // It should set the comptroller correctly.
        assertEq(address(factoryMerkleBase.comptroller()), address(comptroller), "Comptroller mismatch");

        // Set the `merkleBase` to the merkleInstant contract to use it in the tests.
        merkleBase = IStreamArcMerkleBase(merkleInstant);

        // Set the campaign type.
        campaignType = "instant";

        // Claim to collect some fees.
        setMsgSender(users.recipient);
        claim();
    }
}

/*//////////////////////////////////////////////////////////////////////////
                                SHARED TESTS
//////////////////////////////////////////////////////////////////////////*/

contract SetNativeToken_FactoryMerkleInstant_Integration_Concrete_Test is
    FactoryMerkleInstant_Integration_Shared_Test,
    SetNativeToken_Integration_Concrete_Test
{
    function setUp() public override(FactoryMerkleInstant_Integration_Shared_Test, Integration_Test) {
        FactoryMerkleInstant_Integration_Shared_Test.setUp();
    }
}
