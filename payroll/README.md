# PayrollVault

Per-second USDC payroll on Arc. One pool per employer; offers, continuous or payday pay, pause/cancel, runway.

```bash
forge test
RPC_URL=https://rpc.testnet.arc.network forge script script/DeployPayroll.s.sol --rpc-url $RPC_URL --private-key $PRIVATE_KEY --broadcast
```

Amounts are USDC base units (6 dp). Rates are base units per second * 1e18: `monthlyToRate(3_000_000_000)` = $3,000/month.
`period`: 0 continuous, 604800 weekly, 2592000 every 30 days.
