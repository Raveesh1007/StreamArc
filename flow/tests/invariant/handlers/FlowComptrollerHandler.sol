// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IStreamArcFlow } from "src/interfaces/IStreamArcFlow.sol";
import { Store } from "./../stores/Store.sol";
import { BaseHandler } from "./BaseHandler.sol";

contract FlowComptrollerHandler is BaseHandler {
    /*//////////////////////////////////////////////////////////////////////////
                                     MODIFIERS
    //////////////////////////////////////////////////////////////////////////*/

    /// @dev Limit the number of calls to the comptroller functions.
    modifier limitNumberOfCalls(string memory name) {
        vm.assume(totalCalls[name] < 100);
        _;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    CONSTRUCTOR
    //////////////////////////////////////////////////////////////////////////*/

    constructor(Store store_, IStreamArcFlow flow_) BaseHandler(store_, flow_) { }

    /*//////////////////////////////////////////////////////////////////////////
                                    STREAMARC-FLOW
    //////////////////////////////////////////////////////////////////////////*/

    function recover(uint256 tokenIndex)
        external
        limitNumberOfCalls("recover")
        instrument(0, "recover")
        useFuzzedToken(tokenIndex)
    {
        vm.assume(currentToken.balanceOf(address(flow)) > flow.aggregateAmount(currentToken));

        setMsgSender(address(comptroller));
        flow.recover(currentToken, comptroller.admin());
    }
}
