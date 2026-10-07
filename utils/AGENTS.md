# StreamArc EVM Utils

Shared utilities and comptroller contract used across all StreamArc protocols.

## Package Overview

Two main components:

### Comptroller

Standalone admin contract with:

- Fee management across all StreamArc protocols
- Authority over admin functions
- Oracle integration for fee calculations

### Utility Contracts

Reusable base contracts:

- `Adminable`: Admin role management
- `Batch`: Batch transaction support
- `Comptrollerable`: Base for contracts governed by a comptroller
- `NoDelegateCall`: Prevent delegate calls
- `RoleAdminable`: Role-based admin management

## Import Paths

```solidity
import { Adminable } from "@streamarc/evm-utils/src/Adminable.sol";
import { Batch } from "@streamarc/evm-utils/src/Batch.sol";
import { Comptrollerable } from "@streamarc/evm-utils/src/Comptrollerable.sol";
import { NoDelegateCall } from "@streamarc/evm-utils/src/NoDelegateCall.sol";
import { IStreamArcComptroller } from "@streamarc/evm-utils/src/interfaces/IStreamArcComptroller.sol";
```
