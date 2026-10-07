#!/usr/bin/env bash
# Live check on Arc (testnet first!) with REAL USDC. Uses ~3 USDC plus gas.
#   RPC_URL=https://rpc.testnet.arc.network \
#   EMPLOYER_KEY=0x... EMPLOYEE_KEY=0x... ./live-check-arc.sh
# Both wallets need a little USDC for gas (Arc faucet on testnet).
set -euo pipefail

: "${RPC_URL:?}"; : "${EMPLOYER_KEY:?}"; : "${EMPLOYEE_KEY:?}"
ROOT="$(cd "$(dirname "$0")" && pwd)"
CHAIN_ID="$(cast chain-id --rpc-url "$RPC_URL")"
D="$ROOT/deployments/arc-$CHAIN_ID.json"
[ -f "$D" ] || { echo "No deployment file $D. Run deploy-arc.sh first."; exit 1; }
j() { grep "\"$1\"" "$D" | grep -oE '0x[0-9a-fA-F]{40}'; }
LOCKUP=$(j lockup); FLOW=$(j flow)
USDC="${USDC:-0x3600000000000000000000000000000000000000}" # Arc USDC ERC-20 interface (6 decimals)

A0=$(cast wallet address --private-key "$EMPLOYER_KEY"); A1=$(cast wallet address --private-key "$EMPLOYEE_KEY")
send() { cast send --rpc-url "$RPC_URL" --private-key "$@" >/dev/null; }
call() { cast call --rpc-url "$RPC_URL" "$@" | awk '{print $1}'; }
usd() { awk -v v="$1" 'BEGIN{printf "%.6f", v/1e6}'; }

echo "Chain $CHAIN_ID | employer $A0 | employee $A1"
echo "USDC symbol: $(cast call --rpc-url "$RPC_URL" $USDC 'symbol()(string)')  decimals: $(call $USDC 'decimals()(uint8)')"
send "$EMPLOYER_KEY" $USDC "approve(address,uint256)" "$LOCKUP" 2000000
send "$EMPLOYER_KEY" $USDC "approve(address,uint256)" "$FLOW" 1000000

echo "==> Lockup: 2 USDC vesting over 10 minutes"
send "$EMPLOYER_KEY" "$LOCKUP" \
  "createWithDurationsLL((address,address,uint128,address,bool,bool,string),(uint128,uint128),uint40,(uint40,uint40))" \
  "($A0,$A1,2000000,$USDC,true,true,\"arc-live-check\")" "(0,0)" 0 "(0,600)"
LID=$(( $(call "$LOCKUP" "nextStreamId()(uint256)") - 1 ))

echo "==> Flow: 1 USDC deposited, streaming 1 USDC per 10 minutes"
send "$EMPLOYER_KEY" "$FLOW" "createAndDeposit(address,address,uint128,uint40,address,bool,uint128)" \
  "$A0" "$A1" 1666666666666666 0 "$USDC" true 1000000
FID=$(( $(call "$FLOW" "nextStreamId()(uint256)") - 1 ))

echo "Waiting 60 seconds..."
sleep 60
echo "Lockup #$LID withdrawable: $(usd $(call "$LOCKUP" 'withdrawableAmountOf(uint256)(uint128)' $LID))"
echo "Flow   #$FID withdrawable: $(usd $(call "$FLOW" 'withdrawableAmountOf(uint256)(uint128)' $FID))"

BEFORE=$(call $USDC "balanceOf(address)(uint256)" "$A1")
send "$EMPLOYEE_KEY" "$LOCKUP" "withdrawMax(uint256,address)" $LID "$A1"
send "$EMPLOYEE_KEY" "$FLOW" "withdrawMax(uint256,address)" $FID "$A1"
AFTER=$(call $USDC "balanceOf(address)(uint256)" "$A1")
echo "Employee balance change: $(usd $((AFTER - BEFORE))) USDC (amount received minus gas, since gas is paid in the same USDC)"

echo "==> Cleaning up: cancel Lockup (refund unvested) and void Flow (refund deposit)"
send "$EMPLOYER_KEY" "$LOCKUP" "cancel(uint256)" $LID
send "$EMPLOYER_KEY" "$FLOW" "refundMax(uint256)" $FID
echo "Live check passed."
