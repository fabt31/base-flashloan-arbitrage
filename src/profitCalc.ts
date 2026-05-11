import { ethers } from "ethers";
export function estimateProfit(
  amountIn: bigint, price0: number, price1: number, gasCostEth: number
): { profitable: boolean; netProfit: number } {
  const grossProfit = Number(amountIn) * Math.abs(price1 - price0) / price0;
  const gasCostWei = ethers.parseEther(gasCostEth.toString());
  const netProfit = grossProfit - Number(gasCostWei);
  return { profitable: netProfit > 0, netProfit };
}