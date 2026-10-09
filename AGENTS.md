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
| `app`      | Static web app for PayrollVault (viem from esm.sh, no build step)          | n/a                          |

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

App: `cd app && python -m http.server 8787`. URL params override `config.js`: `?rpc=`, `?payroll=`, and `?as=<address>`
for a read-only view. Local demo needs a token at Arc's USDC address:
`cast rpc anvil_setCode 0x3600…0000 "$(cd payroll && forge inspect MockUSDC deployedBytecode)"`.

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
- CI: `ci-payroll.yml` runs payroll tests; `pages.yml` publishes `app/` to GitHub Pages (Settings → Pages → Source:
  GitHub Actions) at `https://raveesh1007.github.io/StreamArc/`.

## Hackathon

- Arc Microgrants (DoraHacks), deadline ~2026-10-14. Must be live on Arc **mainnet** with a public repo and a working
  link.
- ETHGlobal (Arc track). Pre-hackathon baseline is commit `74dad1f`; work after it counts as hackathon work.
- Status (2026-10-09): full suite live on testnet (PayrollVault `0xe9C616E7604b39D11851Ae0467077b10E5111685`); Lockup, Flow
  and PayrollVault checked with real USDC via cast. Not yet on mainnet, Pages not yet enabled.
