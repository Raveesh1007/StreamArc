# StreamArc

Per-second payroll (PayrollVault + web app) and token streaming (Lockup, Flow, Airdrops, Comptroller) on **Arc**,
Circle's USDC-native L1. Repo: `github.com/Raveesh1007/StreamArc`. See [README.md](./README.md) for Arc specifics and
deploy commands; each package has its own `AGENTS.md` with protocol concepts.

## Rules

- **Comments:** none by default. Only when the code can't explain itself, and then one short line. No NatSpec, no
  section banners, no trailing field comments, no paragraphs, no restating the code. Applies to every file, new or
  edited.
- **No duplicate logic:** reuse what exists (in this repo or a dependency) instead of re-writing it.
- **Do not change contract logic under `*/src/`** of `utils`, `lockup`, `flow`, `airdrops`. They are audited code,
  renamed only. Arc work goes in `*/scripts/solidity/arc/`, the root `*.sh` scripts, docs, and the app. `payroll/` is
  our own code and can change; keep its tests passing.
- **Naming:** the project is StreamArc. Credit to the original protocol lives only in `NOTICE` (GPL requirement).
- **Commits:** no AI co-author or "generated with" lines.

## Layout

| Dir        | Role                                                                       | Arc deploy script            |
| ---------- | -------------------------------------------------------------------------- | ---------------------------- |
| `utils`    | `StreamArcComptroller` (UUPS proxy): admin + fees for all protocols        | `DeployArcComptroller.s.sol` |
| `lockup`   | `StreamArcLockup`, `StreamArcBatchLockup`, `LockupNFTDescriptor` (vesting) | `DeployArcLockup.s.sol`      |
| `flow`     | `StreamArcFlow`, `FlowNFTDescriptor` (open-ended streams, debt tracking)   | `DeployArcFlow.s.sol`        |
| `airdrops` | 5 Merkle factories: Instant, LL, LT, VCA, Execute                          | `DeployArcAirdrops.s.sol`    |
| `payroll`  | `PayrollVault`: per-second USDC payroll (offers, payday schedules, runway) | `script/DeployPayroll.s.sol` |
| `app`      | Web app: landing (`/`) + dashboard (`/app/`); Vite, React, shadcn/ui        | n/a                          |

`lockup`, `flow`, `airdrops` depend on `@streamarc/evm-utils` (`file:../utils`); `airdrops` also on `@streamarc/lockup`
(`file:../lockup`). Remappings point into each package's `node_modules/`.

## Toolchain

Foundry, solc 0.8.29, Bun, `evm_version = "shanghai"`. Config: `foundry.base.toml`, extended per package. Profiles:
`default`, `lite` (fast dev), `optimized` (`via_ir`, production, used by `deploy-arc.sh`), `test-optimized`.

```bash
for d in utils lockup flow airdrops; do (cd $d && bun install); done
for d in utils lockup flow airdrops; do (cd $d && FOUNDRY_PROFILE=lite forge test --no-match-path "*fork*"); done
cd lockup && FOUNDRY_PROFILE=lite forge test --match-test <name>
```

Expected: 1,482 pass (utils 200, lockup 616, flow 268, airdrops 398). `payroll` is standalone (forge-std vendored in
`payroll/lib`, no bun): `cd payroll && forge test`, 22 pass.

App: `cd app && npm install && npm run dev` (build: `npm run build` → `app/dist`). URL params override `config.js`:
`?rpc=`, `?payroll=`, and `?as=<address>` for a read-only view. Local demo needs a token at Arc's USDC address:
`cast rpc anvil_setCode 0x3600…0000 "$(cd payroll && forge inspect MockUSDC deployedBytecode)"`.

## App design system

- Every page uses the tokens in `app/src/index.css` (light + `.dark`, toggled in `SiteHeader`, saved in localStorage) and
  the shared `SiteHeader` / `SiteFooter`. Never hard-code colors; check new UI in both themes. Fonts: Bricolage
  Grotesque (headings), Instrument Sans (body), JetBrains Mono (numbers, labels).
- UI primitives come from shadcn/ui in `src/components/ui`; add more with `npx shadcn@latest add <name>`, then fix
  the CLI's `from "cn"` import to `@/lib/utils`. Contract reads, formatting and ABIs live only in `src/lib/vault.ts`.
- Arc and USDC logos are the official files in `src/assets/brand` (white for dark, black for light via `brand.tsx`).
- `AsciiCoin` (three.js + AsciiEffect, lazy-loaded) renders 3D coins from the official logo paths. Section tiles use
  `Tile` from `src/landing/bento.tsx`; animations are keyframes in `index.css`.
- Check layouts at 390px wide; headless Chrome can't go below ~500px, so render the page in a 390px iframe.

## Gotchas

- **Windows bun:** install packages one at a time (parallel installs corrupt the cache). bun can't copy `file:` deps
  (EPERM), leaving them empty. After install:
  `for d in lockup flow airdrops; do cp -r utils/src utils/package.json $d/node_modules/@streamarc/evm-utils/; done` and
  `cp -r lockup/src lockup/tests lockup/package.json airdrops/node_modules/@streamarc/lockup/`.
- CI pins Foundry v1.8.3. Run `forge fmt` with that version; older formatters wrap lines differently.
- Shell scripts are bash (Git Bash/WSL) and need `forge`/`cast` on PATH.
- `deploy-arc.sh` extracts addresses by grepping `console2.log` labels in the Arc scripts. Renaming a label means
  updating the matching `addr "<label>"` call.
- Local anvil and testnet share chain id 5042002, so both write `deployments/arc-5042002.json`. `deployments/` is
  gitignored; publish live addresses in the README.
- `deploy-arc.sh` deploys PayrollVault last and, for non-local RPCs, rewrites `app/config.js` (chain 5042 → mainnet
  RPC/explorer, otherwise testnet). Commit it after a live deploy.
- Networks: testnet `https://rpc.testnet.arc.network` (`rpc.testnet.arc.io` also works), explorer
  `https://explorer.testnet.arc.io`; mainnet `https://rpc.mainnet.arc.io` (chain 5042), explorer
  `https://explorer.arc.io`. Both explorers are Blockscout.
- App sends txs with its own gas estimate +20%; node estimates were too tight for USDC `transferFrom`.
- `ARC.md` names the original protocol, so it stays uncommitted (see the Naming rule).
- CI: `ci-payroll.yml` runs payroll tests. The app deploys on Vercel (project Root Directory `app`, Vite preset).

## ETHGlobal Mumbai plan

- **Framework:** migrate the app to Next.js at the start of the build, before adding protocol UIs (porting later means
  porting twice). Reason: server routes for airdrop CSV → Merkle tree + proof hosting, cached stream listing, and
  per-stream OG share images. Wallet, three.js and AppKit components stay client-only (`"use client"`). If those
  server features are dropped, stay on Vite.
- **ABIs:** generate from forge artifacts (`<pkg>/out/<C>.sol/<C>.json`) into `app/src/abi/*.ts` as `as const`, and
  commit them (the deploy host has no Foundry). Don't hand-write ABIs for Lockup/Flow; their args are nested structs.
- **Addresses:** `deploy-arc.sh` writes every address from `deployments/arc-<chainId>.json` into `app/config.js`
  (not just `payroll`); `lib/chain.ts` exports them as `ADDR`.
- **Code layout:** one `src/lib/<protocol>.ts` per protocol (`vault.ts`, `lockup.ts`, `flow.ts`, `airdrops.ts`) for
  reads and formatting. All writes go through `useTx` with `{ address, abi }`; approve USDC to the target contract
  first.
- **Listing streams:** Lockup and Flow have no per-address getters. Received streams: Blockscout
  `/api/v2/addresses/<user>/nft?type=ERC-721` filtered to the Lockup and Flow addresses (verified that it indexes
  `SAB-LOCKUP`). Created streams: create-event logs filtered by sender.
- **Airdrops:** the leaf is `keccak256(bytes.concat(keccak256(abi.encode(index, recipient, amount))))`, the same as
  OpenZeppelin `StandardMerkleTree` with `["uint256", "address", "uint128"]`. Claimers need hosted proofs.
- **UI:** dashboard tabs Payroll | Vesting | Streams | Airdrops; landing roadmap tiles link to them.
