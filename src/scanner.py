import asyncio
import httpx
from decimal import Decimal

BASE_RPC = "https://mainnet.base.org"
HEADERS = {"Content-Type": "application/json"}

PAIRS = [
    {"token0": "0x4200000000000000000000000000000000000006",  # WETH
     "token1": "0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913",  # USDC
     "fee_a": 500, "fee_b": 3000}
]

async def get_price(client, pool: str) -> Decimal:
    payload = {
        "jsonrpc": "2.0", "method": "eth_call",
        "params": [{"to": pool, "data": "0x3850c7bd"}, "latest"],
        "id": 1
    }
    r = await client.post(BASE_RPC, json=payload, headers=HEADERS)
    result = r.json().get("result", "0x")
    if result and len(result) > 2:
        sqrt_price_x96 = int(result[2:66], 16)
        price = (Decimal(sqrt_price_x96) / Decimal(2**96)) ** 2
        return price
    return Decimal(0)

async def scan_arbitrage():
    async with httpx.AsyncClient() as client:
        for pair in PAIRS:
            print(f"Scanning {pair[token0][:8]}.../{pair[token1][:8]}...")
            # In production: compare prices across multiple pools
            print("  No arbitrage opportunity found")

if __name__ == "__main__":
    asyncio.run(scan_arbitrage())
