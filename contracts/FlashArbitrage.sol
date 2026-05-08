// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IVault {
    function flashLoan(
        IFlashLoanRecipient recipient,
        IERC20[] memory tokens,
        uint256[] memory amounts,
        bytes memory userData
    ) external;
}

interface IFlashLoanRecipient {
    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external;
}

interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint256 amountIn;
        uint256 amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }
    function exactInputSingle(ExactInputSingleParams calldata params) external payable returns (uint256 amountOut);
}

/// @title FlashArbitrage - Flash loan arbitrage on Base L2
contract FlashArbitrage is IFlashLoanRecipient, Ownable {
    IVault public constant BALANCER_VAULT = IVault(0xBA12222222228d8Ba445958a75a0704d566BF2C8);
    ISwapRouter public constant UNISWAP_ROUTER = ISwapRouter(0x2626664c2603336E57B271c5C0b26F421741e481);

    struct ArbitrageParams {
        address tokenIn;
        address tokenMid;
        uint24 fee0;
        uint24 fee1;
        uint256 minProfit;
    }

    event ArbitrageExecuted(address token, uint256 profit);

    constructor() Ownable(msg.sender) {}

    function executeArbitrage(ArbitrageParams calldata params, uint256 amount) external onlyOwner {
        IERC20[] memory tokens = new IERC20[](1);
        uint256[] memory amounts = new uint256[](1);
        tokens[0] = IERC20(params.tokenIn);
        amounts[0] = amount;
        BALANCER_VAULT.flashLoan(this, tokens, amounts, abi.encode(params));
    }

    function receiveFlashLoan(
        IERC20[] memory tokens,
        uint256[] memory amounts,
        uint256[] memory feeAmounts,
        bytes memory userData
    ) external override {
        require(msg.sender == address(BALANCER_VAULT), "Not Balancer");
        ArbitrageParams memory params = abi.decode(userData, (ArbitrageParams));

        uint256 borrowed = amounts[0];
        tokens[0].approve(address(UNISWAP_ROUTER), borrowed);

        // Swap tokenIn -> tokenMid on pool A
        uint256 midAmount = UNISWAP_ROUTER.exactInputSingle(ISwapRouter.ExactInputSingleParams({
            tokenIn: params.tokenIn,
            tokenOut: params.tokenMid,
            fee: params.fee0,
            recipient: address(this),
            amountIn: borrowed,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        }));

        IERC20(params.tokenMid).approve(address(UNISWAP_ROUTER), midAmount);

        // Swap tokenMid -> tokenIn on pool B
        uint256 finalAmount = UNISWAP_ROUTER.exactInputSingle(ISwapRouter.ExactInputSingleParams({
            tokenIn: params.tokenMid,
            tokenOut: params.tokenIn,
            fee: params.fee1,
            recipient: address(this),
            amountIn: midAmount,
            amountOutMinimum: 0,
            sqrtPriceLimitX96: 0
        }));

        uint256 repay = borrowed + feeAmounts[0];
        require(finalAmount >= repay + params.minProfit, "Not profitable");

        tokens[0].transfer(address(BALANCER_VAULT), repay);
        uint256 profit = finalAmount - repay;
        tokens[0].transfer(owner(), profit);
        emit ArbitrageExecuted(address(tokens[0]), profit);
    }

    function withdraw(address token) external onlyOwner {
        IERC20(token).transfer(owner(), IERC20(token).balanceOf(address(this)));
    }
}
