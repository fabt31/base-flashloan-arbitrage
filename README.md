# base-flashloan-arbitrage

> Flash loan arbitrage toolkit for Base L2

Execute atomic flash loan arbitrage across multiple DEXes on Base including Aerodrome, Uniswap v3, BaseSwap, and Balancer pools.

## Architecture

```
User → FlashLoanArbitrage Contract
         ├── Borrow from Balancer (0% fee)
         ├── Swap on DEX A (higher price)
         ├── Swap on DEX B (lower price)
         ├── Repay flash loan
         └── Profit → User
```

## Features

- ⚡ Zero-capital arbitrage using Balancer flash loans
- 🔀 Multi-hop routes across 4+ DEXes
- 🛡️ Reverts atomically if unprofitable
- 📊 Profit simulation before execution
- 🤖 Off-chain opportunity scanner
- ⛽ Gas-aware profitability checks

## Installation

```bash
git clone https://github.com/fabt31/base-flashloan-arbitrage
cd base-flashloan-arbitrage
npm install
forge install
cp .env.example .env
```

## Deployment (Base Mainnet)

```bash
forge script script/Deploy.s.sol --rpc-url $BASE_RPC_URL --broadcast
```

## Supported DEXes

| DEX | Router Address |
|-----|---------------|
| Uniswap v3 | `0x2626664c2603336E57B271c5C0b26F421741e481` |
| Aerodrome | `0xcF77a3Ba9A5CA399B7c97c74d54e5b1Beb874E43` |
| BaseSwap | `0x327Df1E6de05895d2ab08513aaDD9313Fe505d86` |
| Balancer | `0xBA12222222228d8Ba445958a75a0704d566BF2C8` |

## License

MIT — Use at your own risk
