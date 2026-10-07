# StreamArc

Token streaming (Lockup, Flow, Airdrops, Comptroller) on **Arc**, Circle's USDC-native L1. Repo:
`github.com/Raveesh1007/StreamArc`. See [README.md](./README.md) for Arc specifics and deploy commands; each package
has its own `AGENTS.md` with protocol concepts.

## Rules

- **Comments:** none by default. Only when the code can't explain itself, and then one short line. No NatSpec, no
  section banners, no trailing field comments, no paragraphs, no restating the code. Applies to every file, new or
  edited.
- **No duplicate logic:** reuse what exists (in this repo or a dependency) instead of re-writing it.
- **Do not change contract logic under `*/src/`.** The contracts are audited code, renamed only. Arc work goes in
  `*/scripts/solidity/arc/`, the root `*.sh` scripts, docs, and the app.
- **Naming:** the project is StreamArc. Credit to the original protocol lives only in `NOTICE` (GPL requirement).
- **Commits:** no AI co-author or "generated with" lines.

## Layout

| Dir        | Role                                                                          | Arc deploy script            |
| ---------- | ----------------------------------------------------------------------------- | ---------------------------- |
| `utils`    | `StreamArcComptroller` (UUPS proxy): admin + fees for all protocols           | `DeployArcComptroller.s.sol` |
| `lockup`   | `StreamArcLockup`, `StreamArcBatchLockup`, `LockupNFTDescriptor` (vesting)    | `DeployArcLockup.s.sol`      |
| `flow`     | `StreamArcFlow`, `FlowNFTDescriptor` (open-ended streams, debt tracking)      | `DeployArcFlow.s.sol`        |
| `airdrops` | 5 Merkle factories: Instant, LL, LT, VCA, Execute                             | `DeployArcAirdrops.s.sol`    |

`lockup`, `flow`, `airdrops` depend on `@streamarc/evm-utils` (`file:../utils`); `airdrops` also on
`@streamarc/lockup` (`file:../lockup`). Remappings point into each package's `node_modules/`.

## Toolchain

Foundry, solc 0.8.29, Bun, `evm_version = "shanghai"`. Config: `foundry.base.toml`, extended per package. Profiles:
`default`, `lite` (fast dev), `optimized` (`via_ir`, production, used by `deploy-arc.sh`), `test-optimized`.

```bash
for d in utils lockup flow airdrops; do (cd $d && bun install); done
for d in utils lockup flow airdrops; do (cd $d && FOUNDRY_PROFILE=lite forge test --no-match-path "*fork*"); done
cd lockup && FOUNDRY_PROFILE=lite forge test --match-test <name>
```

Expected: 1,482 pass (utils 200, lockup 616, flow 268, airdrops 398).

## Gotchas

- **Windows bun:** install packages one at a time (parallel installs corrupt the cache). bun can't copy `file:` deps
  (EPERM), leaving them empty. After install:
  `for d in lockup flow airdrops; do cp -r utils/src utils/package.json $d/node_modules/@streamarc/evm-utils/; done`
  and `cp -r lockup/src lockup/tests lockup/package.json airdrops/node_modules/@streamarc/lockup/`.
- CI pins Foundry v1.8.3. Run `forge fmt` with that version; older formatters wrap lines differently.
- Shell scripts are bash (Git Bash/WSL) and need `forge`/`cast` on PATH.
- `deploy-arc.sh` extracts addresses by grepping `console2.log` labels in the Arc scripts. Renaming a label means
  updating the matching `addr "<label>"` call.
- Local anvil and testnet share chain id 5042002, so both write `deployments/arc-5042002.json`.

## Hackathon

Arc Microgrants (DoraHacks), deadline ~2026-10-14. Must be live on Arc **mainnet** with a public repo and a working link.
