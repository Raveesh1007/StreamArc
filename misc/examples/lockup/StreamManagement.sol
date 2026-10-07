// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IStreamArcLockup } from "@streamarc/lockup/src/interfaces/IStreamArcLockup.sol";

/// @notice Examples of how to manage StreamArc streams after they have been created.
/// @dev This code is referenced in the docs: https://github.com/Raveesh1007/StreamArc
contract StreamManagement {
    IStreamArcLockup public immutable streamarc;

    constructor(IStreamArcLockup streamarc_) {
        streamarc = streamarc_;
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    02-WITHDRAW
    //////////////////////////////////////////////////////////////////////////*/

    // This function can be called by the sender, recipient, or an approved NFT operator
    function withdraw(uint256 streamId) external payable {
        uint256 fee = streamarc.calculateMinFeeWei(streamId);
        streamarc.withdraw{ value: fee }({ streamId: streamId, to: address(0xCAFE), amount: 1337e18 });
    }

    // This function can be called by the sender, recipient, or an approved NFT operator
    function withdrawMax(uint256 streamId) external payable {
        uint256 fee = streamarc.calculateMinFeeWei(streamId);
        streamarc.withdrawMax{ value: fee }({ streamId: streamId, to: address(0xCAFE) });
    }

    // This function can be called by either the recipient or an approved NFT operator
    function withdrawMultiple(uint256[] calldata streamIds, uint128[] calldata amounts) external payable {
        uint256 maxFeeRequired;

        // The fee required to call withdraw multiple is the maximum of the fees required to withdraw each stream.
        for (uint256 i = 0; i < streamIds.length; i++) {
            uint256 feeForStreamId = streamarc.calculateMinFeeWei(streamIds[i]);
            if (feeForStreamId > maxFeeRequired) {
                maxFeeRequired = feeForStreamId;
            }
        }

        streamarc.withdrawMultiple{ value: maxFeeRequired }({ streamIds: streamIds, amounts: amounts });
    }

    /*//////////////////////////////////////////////////////////////////////////
                                     03-CANCEL
    //////////////////////////////////////////////////////////////////////////*/

    // This function can be called only by the sender
    function cancel(uint256 streamId) external {
        streamarc.cancel(streamId);
    }

    // This function can be called only by the sender
    function cancelMultiple(uint256[] calldata streamIds) external {
        streamarc.cancelMultiple(streamIds);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    04-RENOUNCE
    //////////////////////////////////////////////////////////////////////////*/

    // This function can be called only by the sender
    function renounce(uint256 streamId) external {
        streamarc.renounce(streamId);
    }

    /*//////////////////////////////////////////////////////////////////////////
                                    05-TRANSFER
    //////////////////////////////////////////////////////////////////////////*/

    // This function can be called by either the recipient or an approved NFT operator
    function safeTransferFrom(uint256 streamId) external {
        streamarc.safeTransferFrom({ from: address(this), to: address(0xCAFE), tokenId: streamId });
    }

    // This function can be called by either the recipient or an approved NFT operator
    function transferFrom(uint256 streamId) external {
        streamarc.transferFrom({ from: address(this), to: address(0xCAFE), tokenId: streamId });
    }

    // This function can be called only by the recipient
    function withdrawMaxAndTransfer(uint256 streamId) external payable {
        // Calculate the minimum fee to withdraw the amount.
        uint256 fee = streamarc.calculateMinFeeWei(streamId);

        streamarc.withdrawMaxAndTransfer{ value: fee }({ streamId: streamId, newRecipient: address(0xCAFE) });
    }
}
