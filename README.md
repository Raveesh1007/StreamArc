# StreamArc

Token streaming on Arc, Circle's USDC-native L1: salaries that pay out every second, vesting grants with cliffs, and
airdrops that vest over time.

## Payroll

[`payroll/`](./payroll) holds `PayrollVault`, per-second USDC payroll. [`app/`](./app) is the web app for it.

- **Employers** fund one USDC pool, send offers (one at a time or in bulk), and pick how each person is paid: every
  second, weekly, or every 30 days. Raises apply instantly. Pay cuts and schedule changes need the employee's consent.
  Streams can be paused, resumed or ended. The dashboard shows what's owed, free balance, monthly burn and runway.
- **Employees** accept or decline offers, watch earnings tick up every second, and withdraw whatever has unlocked, to
  any address. Gas on Arc is paid in USDC, so they never need a second token.
- **Safety:** the employer can only withdraw what isn't owed, including pay still waiting for payday. If the pool runs
  dry the debt stays on record and is paid first when the employer tops up. Ending a stream pays the partial period pro
  rata.

```bash
cd payroll && forge test
cd app && python -m http.server 8787
```

The app is static (no build step). `deploy-arc.sh` writes the vault address into `app/config.js`. The
`App: GitHub Pages` workflow publishes `app/` on every push to `main` once Pages is set to "GitHub Actions". For a local
chain, open `http://localhost:8787/?rpc=http://127.0.0.1:8545&payroll=<vault>`. Add `&as=<address>` to view any account
read-only.

## Streaming contracts

Every stream is an ERC-721 with on-chain SVG metadata.

| Package    | Contracts                                                        | Use                                                                     |
| ---------- | ---------------------------------------------------------------- | ----------------------------------------------------------------------- |
| `utils`    | `StreamArcComptroller` (UUPS proxy)                              | Admin and fee settings for all protocols                                |
| `lockup`   | `StreamArcLockup`, `StreamArcBatchLockup`, `LockupNFTDescriptor` | Fixed-amount vesting: linear, cliffs, custom curves, tranches           |
| `flow`     | `StreamArcFlow`, `FlowNFTDescriptor`                             | Open-ended streams (salaries, retainers); top up, pause, adjust, refund |
| `airdrops` | 5 Merkle factories: Instant, LL, LT, VCA, Execute                | Airdrops that pay instantly or vest                                     |

## Arc specifics

- **Networks.** Mainnet chain `5042` (`https://rpc.mainnet.arc.io`), testnet `5042002`. Gas is paid in USDC.
- **USDC** ERC-20 interface: `0x3600000000000000000000000000000000000000`, 6 decimals.
- **Flow rates are 18-decimal** regardless of token: `1e18` = 1 USDC/s. $3,000 per 30 days = `1157407407407407`.
- **Lockup cliffs** vest nothing during the cliff unless a cliff-unlock amount is set. For "25% at cliff, then linear",
  pass the 25% as the cliff unlock amount.
- **Fees are zero.** The Comptroller is deployed with no oracle; a fixed 1:1 oracle could enable fees later.
- **Admin** is the deployer or `ARC_ADMIN`. Use a Safe on mainnet.

## Install and test

Requires Foundry and Bun. solc 0.8.29 is downloaded automatically.

```bash
for d in utils lockup flow airdrops; do (cd $d && bun install); done
for d in utils lockup flow airdrops; do (cd $d && FOUNDRY_PROFILE=lite forge test --no-match-path "*fork*"); done
```

Expected: 1,482 tests pass (utils 200, lockup 616, flow 268, airdrops 398). Fork tests need RPC keys for other chains.

## Deploy

```bash
# Local: full scenario on anvil (vesting, salary, withdrawals, debt, NFT rendering)
anvil --chain-id 5042002 &
RPC_URL=http://127.0.0.1:8545 PRIVATE_KEY=<anvil key 0> ./deploy-arc.sh && ./smoke-test-local.sh

# Testnet, then a live check with ~3 USDC
RPC_URL=https://rpc.testnet.arc.io PRIVATE_KEY=0x... ./deploy-arc.sh
RPC_URL=https://rpc.testnet.arc.io EMPLOYER_KEY=0x... EMPLOYEE_KEY=0x... ./live-check-arc.sh

# Mainnet
RPC_URL=https://rpc.mainnet.arc.io PRIVATE_KEY=0x... ARC_ADMIN=<safe> ./deploy-arc.sh
```

`deploy-arc.sh` builds with the `optimized` profile, deploys Comptroller → Lockup → Flow → Airdrops → PayrollVault, and
writes all addresses to `deployments/arc-<chainId>.json`. On a non-local RPC it also writes the vault address into
`app/config.js`; commit that file to publish the app against the new deployment.

## License

GPL-3.0-or-later. See [LICENSE.md](./LICENSE.md) and [NOTICE](./NOTICE).
