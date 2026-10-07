// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.22;

import { IERC165 } from "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import { IStreamArcLockupRecipient } from "@streamarc/lockup/src/interfaces/IStreamArcLockupRecipient.sol";

contract RecipientHooks is IStreamArcLockupRecipient {
    error CallerNotStreamArcContract(address caller, address streamarcLockup);

    /// @dev The address of the lockup contract. It could be either LockupLinear, LockupDynamic or LockupTranched
    /// depending on which type of streams are supported in this hook.
    address public immutable STREAMARC_LOCKUP;

    mapping(address account => uint256 amount) internal _balances;

    /// @dev Constructor will set the address of the lockup contract.
    constructor(address streamarcLockup_) {
        STREAMARC_LOCKUP = streamarcLockup_;
    }

    // {IERC165-supportsInterface} implementation as required by `IStreamArcLockupRecipient` interface.
    function supportsInterface(bytes4 interfaceId) public pure override(IERC165) returns (bool) {
        return interfaceId == 0xf8ee98d3;
    }

    // This will be called by StreamArc contract when a stream is canceled by the sender.
    function onStreamArcLockupCancel(
        uint256 streamId,
        address sender,
        uint128 senderAmount,
        uint128 recipientAmount
    )
        external
        view
        returns (bytes4 selector)
    {
        // Check: the caller is the lockup contract.
        if (msg.sender != STREAMARC_LOCKUP) {
            revert CallerNotStreamArcContract(msg.sender, STREAMARC_LOCKUP);
        }

        // Unstake the user's NFT.
        _unstake({ nftId: streamId });

        // Update data.
        _updateData(streamId, sender, senderAmount, recipientAmount);

        return IStreamArcLockupRecipient.onStreamArcLockupCancel.selector;
    }

    // This will be called by StreamArc contract when withdraw is called on a stream.
    function onStreamArcLockupWithdraw(
        uint256 streamId,
        address caller,
        address to,
        uint128 amount
    )
        external
        view
        returns (bytes4 selector)
    {
        // Check: the caller is the lockup contract.
        if (msg.sender != STREAMARC_LOCKUP) {
            revert CallerNotStreamArcContract(msg.sender, STREAMARC_LOCKUP);
        }

        // Transfer the withdrawn amount to the original user.
        _transfer(to, amount);

        // Update data.
        _updateData(streamId, caller, amount, 0);

        return IStreamArcLockupRecipient.onStreamArcLockupWithdraw.selector;
    }

    function _unstake(uint256 nftId) internal pure { }
    function _updateData(
        uint256 streamId,
        address sender,
        uint128 senderAmount,
        uint128 recipientAmount
    )
        internal
        pure { }
    function _transfer(address to, uint128 amount) internal pure { }
}
