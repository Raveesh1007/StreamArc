# Sablier on Arc

Sablier is the most widely used token-streaming protocol on EVM chains, but Sablier Labs
entered maintenance mode on 2026-07-13 and won't deploy to new chains. On the same day the
contracts were relicensed from BUSL-1.1 to GPL. This repository brings the full protocol to
Arc, Circle's USDC-native L1.

**The contract source is byte-for-byte Sablier's audited code** (upstream
`sablier-labs/evm-monorepo` at commit `19344450e9182db61e6cb971d3c1bc6ae0cdc70e`). Only
deployment scripts were added, under `*/scripts/solidity/arc/`, plus the shell scripts at
the root. Bob (price-gated vaults) is left out.

## What gets deployed

| Package | Contracts | What it's for |
|---|---|---|
| utils | `SablierComptroller` (UUPS proxy + implementation) | Admin, fee settings for all protocols |
| lockup | `SablierLockup`, `SablierBatchLockup`, `LockupNFTDescriptor` | Fixed-amount vesting: linear, cliffs, custom curves, tranches (token unlocks, grants, bonuses) |
| flow | `SablierFlow`, `FlowNFTDescriptor` | Open-ended streams with no end date: salaries, retainers, subscriptions. Top up, pause, adjust rate, refund |
| airdrops | 5 Merkle factories (Instant, LL, LT, VCA, Execute) | Airdrops that pay instantly or vest over time |

Every stream is an ERC-721 NFT with an on-chain SVG, so it shows up in wallets and can be
transferred if created as transferable.

## Arc-specific setup

- **Admin.** The Comptroller admin is the deployer (or `ARC_ADMIN`). It can upgrade the
  Comptroller and set fees. For mainnet, use a Safe multisig (Safe works on Arc) as `ARC_ADMIN`.
- **Fees are zero.** Sablier's fees are a USD minimum converted to the native token with a
  Chainlink price feed. Arc has none, and the Comptroller treats a missing oracle as zero
  fees, which is also Sablier's own default. Since Arc's native token *is* USDC, a fixed 1:1
  oracle could enable fees later.
- **USDC.** Use the ERC-20 interface at `0x3600000000000000000000000000000000000000`
  (6 decimals). Deposit and withdraw amounts are in 6-decimal units.
- **Flow rates are 18-decimal** regardless of the token: `1e18` = 1 USDC per second.
  $3,000 per 30-day month = `3000e18 / 2592000` = `1157407407407407`.
- **Lockup cliffs.** With a cliff and no cliff unlock amount, nothing vests during the cliff
  and the full amount then streams from the cliff to the end. For "25% at the cliff, then
  linear", pass the 25% as the cliff unlock amount.
- **Gas** is paid in USDC from the same balance, so recipients need no other token.

## Install

Sablier installs dependencies with Bun (npm also works), per package:

```bash
for d in utils lockup flow airdrops; do (cd $d && bun install); done
```

Requires Foundry and solc 0.8.29 (Foundry downloads it automatically).

## Test

```bash
for d in utils lockup flow airdrops; do (cd $d && FOUNDRY_PROFILE=lite forge test --no-match-path "*fork*"); done
```

Result on this fork: 1,482 tests passed, 0 failed (utils 200, lockup 616, flow 268,
airdrops 398). Fork tests are skipped because they need RPC keys for other chains.

## Deploy

```bash
# 1. Arc testnet (chain 5042002); fund the deployer from the Arc faucet
RPC_URL=https://rpc.testnet.arc.network PRIVATE_KEY=0x... ./deploy-arc.sh

# 2. Live check with real USDC (~3 USDC; most is refunded at the end)
RPC_URL=https://rpc.testnet.arc.network EMPLOYER_KEY=0x... EMPLOYEE_KEY=0x... ./live-check-arc.sh

# 3. Arc mainnet: confirm RPC and chain ID at docs.arc.io first
RPC_URL=<arc mainnet rpc> PRIVATE_KEY=0x... ARC_ADMIN=<your safe> ./deploy-arc.sh
```

`deploy-arc.sh` builds with the `optimized` profile (`via_ir`, Sablier's production
settings), deploys in order (Comptroller, Lockup, Flow, Airdrops), and writes every address
to `deployments/arc-<chainId>.json`.

`smoke-test-local.sh` runs a full scenario on a local `anvil --chain-id 5042002` (vesting
with a cliff, a salary stream, withdrawals, running out of deposit, NFT rendering). It has
passed against these scripts.

## License

GPL-3.0-or-later, as relicensed by Sablier Labs on 2026-07-13. Keep the license files and
headers. "Sablier" is Sablier Labs' name; ship the product under your own brand and credit
the protocol.
