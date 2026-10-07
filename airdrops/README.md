# StreamArc Airdrops [![GitHub Actions][gha-badge]][gha] [![Coverage][codecov-badge]][codecov] [![Foundry][foundry-badge]][foundry] [![Twitter][twitter-badge]][twitter]

> [!IMPORTANT]
>
> The license changed from BUSL-1.1 to GPL on 2026-07-13. Read the
> [announcement on X](https://x.com/PaulRBerg/status/2076695661303443667) for details.

In-depth documentation is available at [docs.streamarc.com](https://github.com/Raveesh1007/StreamArc).

## Introduction

StreamArc Airdrops is a collection of smart contracts that allows airdrops of ERC-20 tokens using Merkle trees. It
offers multiple distributions options, including:

1. Instant airdrops: The simplest way to distribute tokens to a list of addresses. Eligible users can claim and receive
   their allocation instantly via a single claim transaction.
2. Vesting airdrops: This is the way to go if you want your users to receive tokens over time through vesting. Upon
   claiming, eligible users will have their tokens streamed through StreamArc over a period specified by the campaign
   creator (aka the campaign owner). This distribution option has been referred to as Airstreams in the past.
3. Variable Claim Amount (VCA) airdrops: This distribution method allows the campaign creator to set up an airdrop with
   linear unlock. However, when a user claims their airdrop, any unvested tokens are forfeited and returned to the
   campaign creator. This approach is useful for airdrops aimed at rewarding loyal users who wait until the end of the
   unlock period to claim their tokens.

StreamArc Airdrops also offer flexibility in configuring the Airdrop campaigns. For example, you can choose between
whether you want vesting to begin at the same time for all users (absolute) or at the time of each claim (relative).

## Documentation

For guides and technical details, check out the [StreamArc documentation](https://github.com/Raveesh1007/StreamArc).

## Getting started

### Install

You can install this repo using either Node.js or Git Submodules.

#### Node.js

This is the recommended approach.

Install this repo using your favorite package manager, e.g., with Bun:

```shell
bun add @streamarc/airdrops
```

#### Git Submodules

This installation method is not recommended, but it is available for those who prefer it.

Install the monorepo and its dependencies using Forge:

```shell
forge install Raveesh1007/StreamArc@airdrops@v3.0.1 OpenZeppelin/openzeppelin-contracts@v5.3.0 PaulRBerg/prb-math@v4.1.0
```

Then, add the following remappings in `remappings.txt`:

```text
@openzeppelin/contracts/=lib/openzeppelin-contracts/contracts/
@prb/math/=lib/prb-math/
@streamarc/evm-utils/=lib/evm-monorepo/utils/
@streamarc/airdrops/=lib/evm-monorepo/airdrops/
@streamarc/lockup/=lib/evm-monorepo/lockup/
```

### Deployments

The list of all deployment addresses can be found [here](https://github.com/Raveesh1007/StreamArc).

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
[gha-badge]: https://github.com/Raveesh1007/StreamArc/actions/workflows/ci-airdrops.yml/badge.svg
[twitter]: https://x.com/StreamArc
[twitter-badge]: https://img.shields.io/twitter/follow/StreamArc
