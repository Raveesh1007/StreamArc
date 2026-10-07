// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { IERC165, ERC165 } from "@openzeppelin/contracts/utils/introspection/ERC165.sol";

import { IStreamArcLockup } from "src/interfaces/IStreamArcLockup.sol";
import { IStreamArcLockupRecipient } from "src/interfaces/IStreamArcLockupRecipient.sol";

contract RecipientGood is IStreamArcLockupRecipient, ERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IStreamArcLockupRecipient).interfaceId;
    }

    function onStreamArcLockupCancel(
        uint256 streamId,
        address sender,
        uint128 senderAmount,
        uint128 recipientAmount
    )
        external
        pure
        override
        returns (bytes4)
    {
        streamId;
        sender;
        senderAmount;
        recipientAmount;

        return IStreamArcLockupRecipient.onStreamArcLockupCancel.selector;
    }

    function onStreamArcLockupWithdraw(
        uint256 streamId,
        address caller,
        address to,
        uint128 amount
    )
        external
        pure
        override
        returns (bytes4)
    {
        streamId;
        caller;
        to;
        amount;

        return IStreamArcLockupRecipient.onStreamArcLockupWithdraw.selector;
    }
}

contract RecipientInterfaceIDIncorrect is IStreamArcLockupRecipient, ERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == 0xffffffff;
    }

    function onStreamArcLockupCancel(uint256, address, uint128, uint128) external pure override returns (bytes4) {
        return IStreamArcLockupRecipient.onStreamArcLockupCancel.selector;
    }

    function onStreamArcLockupWithdraw(uint256, address, address, uint128) external pure override returns (bytes4) {
        return IStreamArcLockupRecipient.onStreamArcLockupWithdraw.selector;
    }
}

contract RecipientInterfaceIDMissing {
    function onStreamArcLockupCancel(uint256, address, uint128, uint128) external pure returns (bytes4) {
        return IStreamArcLockupRecipient.onStreamArcLockupCancel.selector;
    }

    function onStreamArcLockupWithdraw(uint256, address, address, uint128) external pure returns (bytes4) {
        return IStreamArcLockupRecipient.onStreamArcLockupWithdraw.selector;
    }
}

contract RecipientInvalidSelector is IStreamArcLockupRecipient, ERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IStreamArcLockupRecipient).interfaceId;
    }

    function onStreamArcLockupCancel(
        uint256 streamId,
        address sender,
        uint128 senderAmount,
        uint128 recipientAmount
    )
        external
        pure
        override
        returns (bytes4)
    {
        streamId;
        sender;
        senderAmount;
        recipientAmount;

        return 0x10000000;
    }

    function onStreamArcLockupWithdraw(
        uint256 streamId,
        address caller,
        address to,
        uint128 amount
    )
        external
        pure
        override
        returns (bytes4)
    {
        streamId;
        caller;
        to;
        amount;

        return 0x12345678;
    }
}

contract RecipientReentrant is IStreamArcLockupRecipient, ERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IStreamArcLockupRecipient).interfaceId;
    }

    function onStreamArcLockupCancel(
        uint256 streamId,
        address sender,
        uint128 senderAmount,
        uint128 recipientAmount
    )
        external
        override
        returns (bytes4)
    {
        streamId;
        sender;
        senderAmount;
        recipientAmount;

        uint256 feeUSD = 1e8;
        uint256 feeWei = (1e18 * feeUSD) / 3000e8;

        IStreamArcLockup(msg.sender).withdraw{ value: feeWei }(streamId, address(this), recipientAmount);

        return IStreamArcLockupRecipient.onStreamArcLockupCancel.selector;
    }

    function onStreamArcLockupWithdraw(
        uint256 streamId,
        address caller,
        address to,
        uint128 amount
    )
        external
        override
        returns (bytes4)
    {
        streamId;
        caller;
        to;
        amount;

        uint256 feeUSD = 1e8;
        uint256 feeWei = (1e18 * feeUSD) / 3000e8;

        IStreamArcLockup(msg.sender).withdraw{ value: feeWei }(streamId, address(this), amount);

        return IStreamArcLockupRecipient.onStreamArcLockupWithdraw.selector;
    }
}

contract RecipientReverting is IStreamArcLockupRecipient, ERC165 {
    function supportsInterface(bytes4 interfaceId) public view virtual override(IERC165, ERC165) returns (bool) {
        return interfaceId == type(IStreamArcLockupRecipient).interfaceId;
    }

    function onStreamArcLockupCancel(
        uint256 streamId,
        address sender,
        uint128 senderAmount,
        uint128 recipientAmount
    )
        external
        pure
        override
        returns (bytes4)
    {
        streamId;
        sender;
        senderAmount;
        recipientAmount;
        revert("You shall not pass");
    }

    function onStreamArcLockupWithdraw(
        uint256 streamId,
        address caller,
        address to,
        uint128 amount
    )
        external
        pure
        override
        returns (bytes4)
    {
        streamId;
        caller;
        to;
        amount;
        revert("You shall not pass");
    }
}
