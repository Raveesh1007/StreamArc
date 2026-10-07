// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22 <0.9.0;

import { IStreamArcComptroller } from "src/interfaces/IStreamArcComptroller.sol";
import { BaseConstants } from "src/tests/BaseConstants.sol";
import { BaseUtils } from "src/tests/BaseUtils.sol";

contract Utils is BaseConstants, BaseUtils {
    /// @dev Bound the protocol to a valid enum value.
    function boundProtocolEnum(uint8 protocolIndex) internal pure returns (IStreamArcComptroller.Protocol) {
        return IStreamArcComptroller.Protocol(boundUint8(protocolIndex, 0, 3));
    }

    /// @dev Convert value from USD to ETH wei.
    function convertUSDToWei(uint128 amountUSD) internal pure returns (uint256 amountWei) {
        amountWei = (1e18 * uint256(amountUSD)) / ETH_PRICE_USD;
    }

    /// @dev Returns the fee in USD for the given protocol.
    function getFeeInUSD(IStreamArcComptroller.Protocol protocol) internal pure returns (uint256 feeInUSD) {
        if (protocol == IStreamArcComptroller.Protocol.Airdrops) {
            feeInUSD = AIRDROP_MIN_FEE_USD;
        } else if (protocol == IStreamArcComptroller.Protocol.Flow) {
            feeInUSD = FLOW_MIN_FEE_USD;
        } else if (protocol == IStreamArcComptroller.Protocol.Lockup) {
            feeInUSD = LOCKUP_MIN_FEE_USD;
        } else if (protocol == IStreamArcComptroller.Protocol.Staking) {
            feeInUSD = STAKING_MIN_FEE_USD;
        }
    }

    /// @dev Returns the fee in wei for the given protocol.
    function getFeeInWei(IStreamArcComptroller.Protocol protocol) internal pure returns (uint256 feeInWei) {
        if (protocol == IStreamArcComptroller.Protocol.Airdrops) {
            feeInWei = AIRDROP_MIN_FEE_WEI;
        } else if (protocol == IStreamArcComptroller.Protocol.Flow) {
            feeInWei = FLOW_MIN_FEE_WEI;
        } else if (protocol == IStreamArcComptroller.Protocol.Lockup) {
            feeInWei = LOCKUP_MIN_FEE_WEI;
        } else if (protocol == IStreamArcComptroller.Protocol.Staking) {
            feeInWei = STAKING_MIN_FEE_WEI;
        }
    }
}
