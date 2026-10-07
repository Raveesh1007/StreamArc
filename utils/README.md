# StreamArc EVM Utils [![GitHub Actions][gha-badge]][gha] [![Coverage][codecov-badge]][codecov] [![Foundry][foundry-badge]][foundry]

> [!IMPORTANT]
>
> The license changed from BUSL-1.1 to GPL on 2026-07-13. Read the
> [announcement on X](https://x.com/PaulRBerg/status/2076695661303443667) for details.

This package contains the following two sets of contracts:

## StreamArc Comptroller

Its a standalone contract with the following responsibilities:

- Handles state variables, setters and getters, and calculations using external oracles to manage fees across all the
  StreamArc protocols.
- Authority over admin functions across StreamArc protocols.

## Utility contracts

Its a collection of smart contracts used across various StreamArc Solidity projects. The motivation behind this is to
reduce code duplication. The following projects imports these contracts:

- [StreamArc Airdrops](https://github.com/Raveesh1007/StreamArc/tree/main/airdrops)
- [StreamArc Bob](https://github.com/Raveesh1007/StreamArc/tree/main/bob)
- [StreamArc Flow](https://github.com/Raveesh1007/StreamArc/tree/main/flow)
- [StreamArc Lockup](https://github.com/Raveesh1007/StreamArc/tree/main/lockup)

In-depth documentation is available at [docs.streamarc.com](https://github.com/Raveesh1007/StreamArc).

## Repository Structure

This package contains the following subdirectories:

- [`src/interfaces`](./src/interfaces/): Interfaces to be used by external projects.
- [`src/libraries`](./src/libraries/): Helper libraries used by external projects.
- [`src/mocks`](./src/mocks/): Mock contracts used by external projects in tests.
- [`src/tests`](./src/tests/): Helper contracts used by external projects in tests and deployment scripts.

## Install

### Node.js

This is the recommended approach.

Install using your favorite package manager, e.g., with Bun:

```shell
bun add @streamarc/evm-utils
```

### Git Submodules

This installation method is not recommended, but it is available for those who prefer it.

Install the monorepo using Forge:

```shell
forge install Raveesh1007/StreamArc@utils@v2.0.1 OpenZeppelin/openzeppelin-contracts@v5.3.0 smartcontractkit/chainlink-evm@contracts-v1.4.0
```

Then, add the following remapping in `remappings.txt`:

```text
@chainlink/contracts/=lib/chainlink/contracts-evm/
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
@streamarc/evm-utils/=lib/evm-monorepo/utils/
```

## Usage

```solidity
import { Adminable } from "@streamarc/evm-utils/src/Adminable.sol";
import { Batch } from "@streamarc/evm-utils/src/Batch.sol";
import { NoDelegateCall } from "@streamarc/evm-utils/src/NoDelegateCall.sol";

contract MyContract is Adminable, Batch, NoDelegateCall {
    constructor(address initialAdmin) Adminable(initialAdmin) { }

    // Use the `noDelegateCall` modifier to prevent delegate calls.
    function foo() public noDelegateCall { }

    // Use the `onlyAdmin` modifier to restrict access to the admin.
    function editFee(uint256 newFee) public onlyAdmin { }
}
```

## Contributing

This repository is **not accepting pull requests of any kind**, including changes to code comments. Comment-only edits
can change the compiled bytecode, and the source on `main` must remain byte-for-byte verifiable against the
[deployed addresses](https://github.com/Raveesh1007/StreamArc). PRs will be closed without review.

For questions or informal feedback, [open an issue](https://github.com/Raveesh1007/StreamArc/issues/new) or
[start a discussion](https://github.com/Raveesh1007/StreamArc/discussions/new/choose).

## License

See [LICENSE.md](../LICENSE.md).

[codecov]: https://app.codecov.io/gh/Raveesh1007/StreamArc
[codecov-badge]: https://codecov.io/gh/Raveesh1007/StreamArc/graph/badge.svg
[foundry]: https://getfoundry.sh
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[gha]: https://github.com/Raveesh1007/StreamArc/actions
[gha-badge]: https://github.com/Raveesh1007/StreamArc/actions/workflows/ci-utils.yml/badge.svg
