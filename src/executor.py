import asyncio, os
from web3 import AsyncWeb3, WebSocketProvider

async def run_executor():
    w3 = AsyncWeb3(WebSocketProvider(os.getenv("BASE_WS_RPC", "wss://mainnet.base.org")))
    print("Arbitrage executor started on Base")
    while True:
        block = await w3.eth.get_block("latest")
        print(f"Block {block.number} — scanning for arb opportunities...")
        await asyncio.sleep(2)

if __name__ == "__main__":
    asyncio.run(run_executor())