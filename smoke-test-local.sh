#!/usr/bin/env bash
# End-to-end smoke test against a LOCAL anvil chain (needs evm_increaseTime).
#   anvil --chain-id 5042002 &
#   RPC_URL=http://127.0.0.1:8545 PRIVATE_KEY=<anvil key 0> ./deploy-arc.sh
#   ./smoke-test-local.sh
set -euo pipefail

RPC="${RPC_URL:-http://127.0.0.1:8545}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
CHAIN_ID="$(cast chain-id --rpc-url "$RPC")"
D="$ROOT/deployments/arc-$CHAIN_ID.json"
j() { grep "\"$1\"" "$D" | grep -oE '0x[0-9a-fA-F]{40}'; }
LOCKUP=$(j lockup); FLOW=$(j flow)

# anvil default accounts 0 (employer) and 1 (employee)
PK0=0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80
PK1=0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
A0=$(cast wallet address --private-key $PK0); A1=$(cast wallet address --private-key $PK1)
send() { cast send --rpc-url "$RPC" --private-key "$@" >/dev/null; }
bal() { cast call --rpc-url "$RPC" "$USDC" "balanceOf(address)(uint256)" "$1" | awk '{print $1}'; }
warp() { cast rpc --rpc-url "$RPC" evm_increaseTime "$1" >/dev/null; cast rpc --rpc-url "$RPC" evm_mine >/dev/null; }
usd() { awk -v v="$1" 'BEGIN{printf "%.2f", v/1e6}'; }

echo "==> Deploying 6-decimal mock USDC"
USDC=$(cd "$ROOT/utils" && forge create scripts/solidity/arc/MockUSDC.sol:MockUSDC --rpc-url "$RPC" \
  --private-key $PK0 --broadcast 2>&1 | grep -oE 'Deployed to: 0x[0-9a-fA-F]{40}' | grep -oE '0x.*')
echo "    USDC: $USDC"
send $PK0 "$USDC" "mint(address,uint256)" "$A0" 100000000000          # 100,000 USDC
send $PK0 "$USDC" "approve(address,uint256)" "$LOCKUP" 100000000000
send $PK0 "$USDC" "approve(address,uint256)" "$FLOW" 100000000000

echo "==> Lockup: vest 12,000 USDC over 12 months; 25% (3,000) unlocks at a 3-month cliff, rest linear"
send $PK0 "$LOCKUP" \
  "createWithDurationsLL((address,address,uint128,address,bool,bool,string),(uint128,uint128),uint40,(uint40,uint40))" \
  "($A0,$A1,12000000000,$USDC,true,true,\"vesting\")" "(0,3000000000)" 0 "(7776000,31104000)"
LID=$(( $(cast call --rpc-url "$RPC" "$LOCKUP" "nextStreamId()(uint256)" | awk '{print $1}') - 1 ))

echo "==> Flow: stream \$3,000/month salary, deposit 9,000 USDC"
# Flow rates are 18-decimal fixed point regardless of token decimals: 3000 / 2592000 tokens per second
RATE=1157407407407407
send $PK0 "$FLOW" "createAndDeposit(address,address,uint128,uint40,address,bool,uint128)" \
  "$A0" "$A1" $RATE 0 "$USDC" true 9000000000
FID=$(( $(cast call --rpc-url "$RPC" "$FLOW" "nextStreamId()(uint256)" | awk '{print $1}') - 1 ))

echo "==> 1 month passes"
warp 2592000
LW=$(cast call --rpc-url "$RPC" "$LOCKUP" "withdrawableAmountOf(uint256)(uint128)" $LID | awk '{print $1}')
FW=$(cast call --rpc-url "$RPC" "$FLOW" "withdrawableAmountOf(uint256)(uint128)" $FID | awk '{print $1}')
echo "    Lockup withdrawable (inside cliff): $(usd $LW)  (expect 0.00)"
echo "    Flow withdrawable:                  $(usd $FW)  (expect ~3000.00)"

echo "==> Employee withdraws salary"
send $PK1 "$FLOW" "withdrawMax(uint256,address)" $FID "$A1"
echo "    Employee USDC: $(usd $(bal $A1))"

echo "==> 5 more months pass (6 months in total)"
warp 12960000
LW=$(cast call --rpc-url "$RPC" "$LOCKUP" "withdrawableAmountOf(uint256)(uint128)" $LID | awk '{print $1}')
echo "    Lockup withdrawable at month 6: $(usd $LW)  (expect 6000.00: 3,000 at cliff + 3/9 of the remaining 9,000)"
send $PK1 "$LOCKUP" "withdrawMax(uint256,address)" $LID "$A1"
send $PK1 "$FLOW" "withdrawMax(uint256,address)" $FID "$A1"
echo "    Employee USDC: $(usd $(bal $A1))  (expect ~15000.00: 6,000 vested + 9,000 salary)"

echo "==> Flow deposit (9,000) ran out after 3 months; unpaid salary is tracked as debt"
DEBT=$(cast call --rpc-url "$RPC" "$FLOW" "uncoveredDebtOf(uint256)(uint256)" $FID | awk '{print $1}')
echo "    Uncovered debt: $(usd $DEBT)  (expect 9000.00: 18,000 owed - 9,000 deposited)"

echo "==> Stream NFTs render"
for c in "$LOCKUP $LID" "$FLOW $FID"; do set -- $c
  URI=$(cast call --rpc-url "$RPC" "$1" "tokenURI(uint256)(string)" "$2")
  echo "    tokenURI($2) on $1: ${#URI} chars, starts ${URI:1:29}"
done
echo "==> Smoke test passed"
