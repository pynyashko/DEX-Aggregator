# DEX Aggregator

## 1. Introduction

Decentralized exchange (DEX) aggregator that integrates Uniswap V2-like and Uniswap V3 protocols. The system dynamically selects the optimal trading route based on liquidity and pricing data.

## 2. Problem’s solution overview

- Automatic routing: choosing the best route between UniswapV2-like pools and Uniswap V3 pools
- On-chain price discovery, using:
  - getAmountsOut (V2)
  - Quoter (V3)
- Unified interface:
  - swap(tokenIn, tokenOut, amountIn, amountOut)

## 3. System architecture

### Components:


User
↓
DEXAggregator (Proxy)
↓
Adapters
├── V2Adapter
└── V3Adapter
↓
External Protocols
├── Uniswap V2 Router
└── Uniswap V3 Router + Quoter


### DEXAggregator (main contract)

Functions:
- route selection
- execution
- access control
- upgradeability

### V2Adapter (Responsible for interacting with UniswapV2)

Functions:
- quote()
- swap()

### V3Adapter (Works with UniswapV3)

Functions:
- quoteBest()
- swap()

Supports fee tiers:
- 0.05% (500)
- 0.3% (3000)
- 1% (10000)

## 4. Routing Algorithm

- **Single-hop routing**

Для пары (tokenIn → tokenOut):
```
V2_out = V2.quote(...)
V3_out = max over fee tiers (V3.quote(...))
Best_out = max(V2_out, V3_out)
```

- **Route Selection**
```
if V3_out > V2_out:
	use V3
else:
	use V2
```

- **Edge Case Handling**
```
if V2_out == 0 && V3_out == 0:
	no route found
```

## 5. Pricing Models

- **Uniswap V2 (Constant Product)**

Formula: $x\cdot y = k$

Output: $$ amountOut = \frac{amountIn\cdot 997 \cdot reserveOut}{reserveIn \cdot 1000 + amountIn\cdot 997}$$

- **Uniswap V3 (Concentrated Liquidity)**

Price: $$ P = (\frac{\sqrt{PriceX96}}{2^{96}})^2 $$

## 6. Swap Execution Flow

Step-by-step:

1. User вызывает swap()
2. Контракт получает токены: transferFrom(user → aggregator)
3. Делается approve на adapters
4. Получаются quotes:
   - V2
   - V3
5. Выбирается лучший маршрут
6. Выполняется swap
7. Результат отправляется пользователю

## 7. Security Considerations

- Reentrancy Protections  
	  nonReentrant
- Slippage Control  
	  require(amountOut >= minOut)
- Safe ERC20
- Approval Safety
- Upgradeability (UUPS)  
		Используется UUPS Proxy Pattern:
- **Risks**  
	  MEV (front-running)  
	  Low liquidity on testnet  
	  External protocol risk

## 8. Testing Strategy

- **Fork Testing**  
	Using Sepolia fork

- **Test Cases**
  - quote correctness
  - swap execution
  - revert conditions:
    - zero amount
    - same token
    - paused

- **Edge Cases**
  - no liquidity
  - router failure
  - token approval failure

## 9. Deployment

- **Network** (Sepolia Testnet)
- **Tools**
  - Foundry
  - Forge scripts
- **Flow**
  - Deploy adapters
  - Deploy implementation
  - Deploy proxy
  - Initialize

## 10. Limitations

- **Current:**
  - only single-hop routing
  - no split routing
  - no gas optimization
- **Testnet limitations**
  - low liquidity
  - unstable pricing

## 11. Conclusion

DEX Aggregator demonstrates:

- effective pooling of liquidity
- on-chain decision making
- secure architecture
