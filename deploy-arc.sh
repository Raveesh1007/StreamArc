#!/usr/bin/env bash
# Deploys the full streaming suite (Comptroller, Lockup, Flow, Airdrops) to Arc.
#
# Usage:
#   RPC_URL=https://rpc.testnet.arc.network PRIVATE_KEY=0x... ./deploy-arc.sh
#
# Optional env:
#   ARC_ADMIN     Admin of the Comptroller (defaults to the deployer address)
#   COMPTROLLER   Reuse an existing Comptroller instead of deploying one
#   PROFILE       Foundry profile (default: optimized, the audited build settings)
#
# Writes all addresses to deployments/arc-<chainId>.json.

set -euo pipefail

: "${RPC_URL:?Set RPC_URL to an Arc RPC endpoint}"
: "${PRIVATE_KEY:?Set PRIVATE_KEY to the deployer key (funded with USDC for gas)}"
PROFILE="${PROFILE:-optimized}"

ROOT="$(cd "$(dirname "$0")" && pwd)"
CHAIN_ID="$(cast chain-id --rpc-url "$RPC_URL")"
DEPLOYER="$(cast wallet address --private-key "$PRIVATE_KEY")"
echo "Deploying to chain $CHAIN_ID from $DEPLOYER (profile: $PROFILE)"

# Runs a forge script inside a package and prints its console output.
run() {
  local pkg="$1" script="$2"
  (cd "$ROOT/$pkg" && FOUNDRY_PROFILE="$PROFILE" forge script "$script" \
    --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" --broadcast --slow 2>&1)
}

# Pulls the address printed after a given label in a script's console output.
addr() { grep -E "^ *$1:? " | grep -oE '0x[0-9a-fA-F]{40}' | head -1; }

if [ -z "${COMPTROLLER:-}" ]; then
  echo "==> Comptroller"
  OUT="$(run utils scripts/solidity/arc/DeployArcComptroller.s.sol)"
  echo "$OUT" | grep -E "Comptroller|Admin" || { echo "$OUT"; exit 1; }
  COMPTROLLER="$(echo "$OUT" | addr "Comptroller proxy")"
  COMPTROLLER_IMPL="$(echo "$OUT" | addr "Comptroller implementation")"
fi
export COMPTROLLER

echo "==> Lockup"
OUT="$(run lockup scripts/solidity/arc/DeployArcLockup.s.sol)"
echo "$OUT" | grep -E "StreamArc|Descriptor" || { echo "$OUT"; exit 1; }
LOCKUP="$(echo "$OUT" | addr "StreamArcLockup")"
BATCH_LOCKUP="$(echo "$OUT" | addr "StreamArcBatchLockup")"
LOCKUP_NFT="$(echo "$OUT" | addr "LockupNFTDescriptor")"

echo "==> Flow"
OUT="$(run flow scripts/solidity/arc/DeployArcFlow.s.sol)"
echo "$OUT" | grep -E "StreamArc|Descriptor" || { echo "$OUT"; exit 1; }
FLOW="$(echo "$OUT" | addr "StreamArcFlow")"
FLOW_NFT="$(echo "$OUT" | addr "FlowNFTDescriptor")"

echo "==> Airdrops"
OUT="$(run airdrops scripts/solidity/arc/DeployArcAirdrops.s.sol)"
echo "$OUT" | grep -E "Factory" || { echo "$OUT"; exit 1; }
F_EXECUTE="$(echo "$OUT" | addr "FactoryMerkleExecute")"
F_INSTANT="$(echo "$OUT" | addr "FactoryMerkleInstant")"
F_LL="$(echo "$OUT" | addr "FactoryMerkleLL")"
F_LT="$(echo "$OUT" | addr "FactoryMerkleLT")"
F_VCA="$(echo "$OUT" | addr "FactoryMerkleVCA")"

echo "==> Payroll"
OUT="$(cd "$ROOT/payroll" && forge script script/DeployPayroll.s.sol \
  --rpc-url "$RPC_URL" --private-key "$PRIVATE_KEY" --broadcast --slow 2>&1)"
echo "$OUT" | grep -E "PayrollVault" || { echo "$OUT"; exit 1; }
PAYROLL="$(echo "$OUT" | addr "PayrollVault")"

mkdir -p "$ROOT/deployments"
FILE="$ROOT/deployments/arc-$CHAIN_ID.json"
cat > "$FILE" <<EOF
{
  "chainId": $CHAIN_ID,
  "deployer": "$DEPLOYER",
  "comptroller": "$COMPTROLLER",
  "comptrollerImplementation": "${COMPTROLLER_IMPL:-}",
  "lockup": "$LOCKUP",
  "batchLockup": "$BATCH_LOCKUP",
  "lockupNFTDescriptor": "$LOCKUP_NFT",
  "flow": "$FLOW",
  "flowNFTDescriptor": "$FLOW_NFT",
  "factoryMerkleExecute": "$F_EXECUTE",
  "factoryMerkleInstant": "$F_INSTANT",
  "factoryMerkleLL": "$F_LL",
  "factoryMerkleLT": "$F_LT",
  "factoryMerkleVCA": "$F_VCA",
  "payrollVault": "$PAYROLL"
}
EOF

if [ "$CHAIN_ID" = 5042 ]; then
  NET="Arc" PUB_RPC="https://rpc.mainnet.arc.io" EXPLORER="https://explorer.arc.io"
else
  NET="Arc Testnet" PUB_RPC="https://rpc.testnet.arc.network" EXPLORER="https://explorer.testnet.arc.io"
fi
case "$RPC_URL" in
  *127.0.0.1* | *localhost*) ;;
  *)
    cat > "$ROOT/app/config.js" <<EOF
export default {
  chainId: $CHAIN_ID,
  name: "$NET",
  rpc: "$PUB_RPC",
  explorer: "$EXPLORER",
  usdc: "0x3600000000000000000000000000000000000000",
  payroll: "$PAYROLL",
};
EOF
    echo "==> App config written to app/config.js"
    ;;
esac
echo "==> Done. Addresses written to $FILE"
cat "$FILE"
