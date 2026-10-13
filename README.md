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
cd app && npm install && npm run dev
```

The app is a Vite + React site: a landing page at `/` and the dashboard at `/app/`. `app/config.json` holds both Arc
mainnet and testnet; the dashboard has a Mainnet / Testnet switch (remembered per browser), and `?network=testnet` opens
a link on testnet. It deploys on Vercel with Root Directory `app` (Vite preset, output `dist`). For a local chain, open
`http://localhost:5173/app/?rpc=http://127.0.0.1:8545&payroll=<vault>`. Add `&as=<address>` to view any account
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
writes all addresses to `deployments/arc-<chainId>.json`. On a non-local RPC it also sets that network's vault address
in `app/config.json`, leaving the other network untouched; commit that file to publish the app against it.

## Deployments

Same addresses on Arc mainnet (`5042`, [explorer](https://explorer.arc.io)) and testnet (`5042002`,
[explorer](https://explorer.testnet.arc.io)): one deployer, same nonces.

| Contract                    | Address                                      |
| --------------------------- | -------------------------------------------- |
| PayrollVault                | `0xe9C616E7604b39D11851Ae0467077b10E5111685` |
| Comptroller (proxy)         | `0xB6056CA73Beaa2baF03419f3CAA2e0Ba564Fe727` |
| Comptroller implementation  | `0x9b9B8d20EB83b7A67aDC742D3db83cc45f4C9198` |
| Lockup                      | `0x7FB00Dd54C509D1b698610aC781cf92829497F08` |
| BatchLockup                 | `0xFfd8FE53f6C29Ed6BE387e06580675305439d0Da` |
| LockupNFTDescriptor         | `0xF13d46904999B77f9134B2124a602750A067119c` |
| Flow                        | `0x55F92fa58a5AB9227E40c5393DAAe8FEb43D0803` |
| FlowNFTDescriptor           | `0xc509b8b301094bAbA6a5012C1C921178dEA838B3` |
| FactoryMerkleInstant        | `0x185397C53851DdBb8Dc81Bf454d31536F2Bd3AeF` |
| FactoryMerkleLL             | `0x333D1EFFdF449f821d53117743dfB10eCC320471` |
| FactoryMerkleLT             | `0x957508527fE3e4659255907D5d69B9e83218C995` |
| FactoryMerkleVCA            | `0x4990425EE5377A19ec56734EeAF3800c8fF2d2Be` |
| FactoryMerkleExecute        | `0x10E1519e5dC3B6cB94Ad39419501C8d918eb4fAE` |

## License

GPL-3.0-or-later. See [LICENSE.md](./LICENSE.md) and [NOTICE](./NOTICE).
