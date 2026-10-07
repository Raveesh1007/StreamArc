// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IComptrollerable } from "src/interfaces/IComptrollerable.sol";
import { IStreamArcComptroller } from "src/interfaces/IStreamArcComptroller.sol";
import { Errors } from "src/libraries/Errors.sol";
import { ComptrollerWithoutMinimalInterfaceId } from "src/mocks/ComptrollerMock.sol";
import { StreamArcComptroller } from "src/StreamArcComptroller.sol";

import { Base_Test } from "../../../../Base.t.sol";

contract SetComptroller_Integration_Concrete_Test is Base_Test {
    IStreamArcComptroller internal newComptroller;

    function setUp() public override {
        super.setUp();

        // Deploy a new comptroller.
        newComptroller = new StreamArcComptroller(admin);
    }

    function test_RevertWhen_CallerNotCurrentComptroller() external {
        setMsgSender(admin);
        vm.expectRevert(
            abi.encodeWithSelector(Errors.Comptrollerable_CallerNotComptroller.selector, comptroller, admin)
        );
        comptrollerableMock.setComptroller(newComptroller);
    }

    function test_RevertWhen_NewComptrollerWithoutMinimalInterfaceId() external whenCallerCurrentComptroller {
        address newComptrollerWithoutMinimalInterfaceId = address(new ComptrollerWithoutMinimalInterfaceId());

        vm.expectRevert(
            abi.encodeWithSelector(
                Errors.Comptrollerable_UnsupportedInterfaceId.selector,
                comptroller,
                newComptrollerWithoutMinimalInterfaceId,
                comptroller.MINIMAL_INTERFACE_ID()
            )
        );
        comptrollerableMock.setComptroller(IStreamArcComptroller(newComptrollerWithoutMinimalInterfaceId));
    }

    function test_WhenNewComptrollerWithMinimalInterfaceId() external whenCallerCurrentComptroller {
        vm.expectEmit({ emitter: address(comptrollerableMock) });
        emit IComptrollerable.SetComptroller(comptroller, newComptroller);
        comptrollerableMock.setComptroller(newComptroller);
        assertEq(address(comptrollerableMock.comptroller()), address(newComptroller), "Comptroller not set correctly");
    }
}
