// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IStreamArcComptroller } from "src/interfaces/IStreamArcComptroller.sol";
import { Errors } from "src/libraries/Errors.sol";

import { Base_Test } from "../../../../Base.t.sol";

contract DisableCustomFeeUSDFor_Integration_Concrete_Test is Base_Test {
    function setUp() public override {
        Base_Test.setUp();

        // Set custom fee for sender.
        comptroller.setCustomFeeUSDFor(IStreamArcComptroller.Protocol.Airdrops, users.sender, 0);
        comptroller.setCustomFeeUSDFor(IStreamArcComptroller.Protocol.Flow, users.sender, 0);
        comptroller.setCustomFeeUSDFor(IStreamArcComptroller.Protocol.Lockup, users.sender, 0);
        comptroller.setCustomFeeUSDFor(IStreamArcComptroller.Protocol.Staking, users.sender, 0);
    }

    function test_RevertWhen_CallerWithoutFeeManagementRole(uint8 protocolIndex) external whenCallerNotAdmin {
        IStreamArcComptroller.Protocol protocol = boundProtocolEnum(protocolIndex);
        setMsgSender(users.eve);
        vm.expectRevert(abi.encodeWithSelector(Errors.UnauthorizedAccess.selector, users.eve, FEE_MANAGEMENT_ROLE));
        comptroller.disableCustomFeeUSDFor(protocol, users.sender);
    }

    function test_WhenCallerWithFeeManagementRole(uint8 protocolIndex) external whenCallerNotAdmin {
        IStreamArcComptroller.Protocol protocol = boundProtocolEnum(protocolIndex);
        setMsgSender(users.accountant);

        // Disable the custom fee.
        _disableCustomFeeUSDFor(protocol, users.accountant);
    }

    function test_WhenCallerAdmin(uint8 protocolIndex) external {
        IStreamArcComptroller.Protocol protocol = boundProtocolEnum(protocolIndex);

        // Disable the custom fee.
        _disableCustomFeeUSDFor(protocol, admin);
    }

    /// @dev Shared logic to test disabling the custom fee.
    function _disableCustomFeeUSDFor(IStreamArcComptroller.Protocol protocol, address caller) private {
        // It should have custom fee set.
        assertEq(comptroller.calculateMinFeeWeiFor(protocol, users.sender), 0, "custom fee set");

        // It should emit an {UpdateCustomFeeUSD} event.
        vm.expectEmit({ emitter: address(comptroller) });
        emit IStreamArcComptroller.UpdateCustomFeeUSD({
            protocol: protocol,
            caller: caller,
            user: users.sender,
            previousMinFeeUSD: 0,
            newMinFeeUSD: getFeeInUSD(protocol)
        });

        // Disable the custom fee.
        comptroller.disableCustomFeeUSDFor(protocol, users.sender);

        // It should disable the custom fee.
        assertEq(comptroller.calculateMinFeeWeiFor(protocol, users.sender), getFeeInWei(protocol), "custom fee not set");
        assertNotEq(comptroller.calculateMinFeeWeiFor(protocol, users.sender), 0, "custom fee not disabled");
    }
}
