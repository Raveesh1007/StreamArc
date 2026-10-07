# StreamArc Lockup [![GitHub Actions][gha-badge]][gha] [![Coverage][codecov-badge]][codecov] [![Foundry][foundry-badge]][foundry] [![Twitter][twitter-badge]][twitter]

> [!IMPORTANT]
>
> The license changed from BUSL-1.1 to GPL on 2026-07-13. Read the
> [announcement on X](https://x.com/PaulRBerg/status/2076695661303443667) for details.

In-depth documentation is available at [docs.streamarc.com](https://github.com/Raveesh1007/StreamArc).

## Background

StreamArc Lockup is a token distribution protocol that enables onchain vesting and airdrops. Our flagship model is the
linear stream, which distributes tokens on a continuous, by-the-second basis.

The way it works is that the sender of a payment stream first deposits a specific amount of ERC-20 tokens in a contract.
Then, the contract progressively allocates the funds to the recipient, who can access them as they become available over
time. The payment rate is influenced by various factors, including the start and end times, as well as the total amount
of tokens deposited.

## Install

### Node.js

This is the recommended approach.

Install Lockup using your favorite package manager, e.g., with Bun:

```shell
bun add @streamarc/lockup
```

### Git Submodules

This installation method is not recommended, but it is available for those who prefer it.

Install the monorepo and its dependencies using Forge:

```shell
forge install Raveesh1007/StreamArc@lockup@v4.0.1 OpenZeppelin/openzeppelin-contracts@v5.3.0 PaulRBerg/prb-math@v4.1.0 smartcontractkit/chainlink-evm@contracts-v1.4.0
```

Then, add the following remappings in `remappings.txt`:

```text
@chainlink/contracts/=lib/chainlink/contracts-evm/
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
@prb/math/=lib/prb-math/
@streamarc/evm-utils/=lib/evm-monorepo/utils/
@streamarc/lockup/=lib/evm-monorepo/lockup/
```

## Usage

This is just a glimpse of StreamArc Lockup. For more guides and examples, see the
[documentation](https://github.com/Raveesh1007/StreamArc).

```solidity
import { IStreamArcLockup } from "@streamarc/lockup/src/interfaces/IStreamArcLockup.sol";

contract MyContract {
  IStreamArcLockup lockup;

  function buildSomethingWithStreamArc() external {
    // ...
  }
}
```

## Architecture

Lockup uses a singleton-style architecture, where all streams are managed in the `StreamArcLockup` contract. That is,
StreamArc does not deploy a new contract for each distribution model or stream. It bundles all streams into a single
contract, which is more gas-efficient and easier to maintain.

For more information, see the [Technical Overview](https://github.com/Raveesh1007/StreamArc) in our docs, as well as
these [diagrams](https://github.com/Raveesh1007/StreamArc).

## Deployments

The list of all deployment addresses can be found [here](https://github.com/Raveesh1007/StreamArc). For
guidance on the deployment scripts, see the [Deployments Guide](https://github.com/Raveesh1007/StreamArc) in
our docs.

## Security

The codebase has undergone rigorous audits by leading security experts from Cantina, as well as independent auditors.
For a comprehensive list of all audits conducted, please click [here](https://github.com/streamarc-labs/audits).

For any security-related concerns, please refer to the [SECURITY](../SECURITY.md) policy.

## Contributing

This repository is **not accepting pull requests of any kind**, including changes to code comments. Comment-only edits
can change the compiled bytecode, and the source on `main` must remain byte-for-byte verifiable against the
[deployed addresses](https://github.com/Raveesh1007/StreamArc). PRs will be closed without review.

For questions or informal feedback, [open an issue](https://github.com/Raveesh1007/StreamArc/issues/new) or
[start a discussion](https://github.com/Raveesh1007/StreamArc/discussions/new/choose).

## License

See [LICENSE.md](../LICENSE.md).

[codecov]: https://app.codecov.io/gh/Raveesh1007/StreamArc
[codecov-badge]: https://codecov.io/gh/Raveesh1007/StreamArc/branch/main/graph/badge.svg
[foundry]: https://getfoundry.sh
[foundry-badge]: https://img.shields.io/badge/Built%20with-Foundry-FFDB1C.svg
[gha]: https://github.com/Raveesh1007/StreamArc/actions
[gha-badge]: https://github.com/Raveesh1007/StreamArc/actions/workflows/ci-lockup.yml/badge.svg
[twitter]: https://x.com/StreamArc
[twitter-badge]: https://img.shields.io/twitter/follow/StreamArc
