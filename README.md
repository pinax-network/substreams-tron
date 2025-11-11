# Tron: `Substreams`

> Substreams packages for the Tron blockchain.

## Substreams Packages

- [x] `/transfers`
  - [x] TRC20 `Transfer`
  - [x] Native (from `value` field)
  - [x] WETH `Deposit`/`Withdrawal`
- [x] JustSwap V1
- [x] SunSwap V2
- [x] SunPump V1

### DEX protocols

> Ordered by most swaps on TRON Mainnet.

| DEX                         | Protocol | Factory Address                     |
| --------------------------- | -------- | ----------------------------------- |
| SunSwap V1 (JustSwap)       | `justswap` | `TXk8rQSAvPvBBNtqSoY6nCfsXWCSSpTVQF` |
| SunSwap V2                  | `sunswap`  | `TKWJdrQkqHisa1X8HUdHEfREvTzw4pMAaY` |
| SunPump                     | `sunpump`  | `TTfvyrAz86hbZk5iDpKD78pqLGgi8C7AAw` |
| USwap                       | `sunswap`  | `TQ4F8Gr1qRKcMva64qYweAJNAVtgfj6ZJd` |
| SunSwap 1.5 (JustSwap)      | `justswap` | `TB2LM4iegvhPJGWn9qizeefkPMm7bqqaMs` |
| ISwap V1                    | `sunswap`  | `TPvaMEL5oY2gWsJv7MDjNQh2dohwvwwVwx` |
| JustMoney                   | `sunswap`  | `TBfTeNjh7k8PbkTad8z6WS2vqh7SQZUfQ8` |
| SocialSwap V2               | `sunswap`  | `TSzrq5j2Btn27eVcBAvZj9WQK3FhURamDQ` |
| ISwap V2                    | `sunswap`  | `TJL9Tj2rf5WPUkaYMzbvWErn6M8wYRiHG7` |
| SocialSwap V1               | `sunswap`  | `TN57jo2jGQz3v5YDybyLFHFtvkmRQvCNFz` |
| WhiteSwap                   | `sunswap`  | `TZENwkSudHRjeufNrQYAPtCmcuNRw2HNYT` |
| Oikos Swap V2               | `sunswap`  | `TALZyLNFk1ftUkJSy9bYZVLgBSuWzKMcR2` |

## Event signatures

> `topic0` is derived from `keccak256(event_signature)`.

| event | topic0 |
|---------|------|
| Transfer |`ddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef` |
| Deposit | `e1fffcc4923d04b559f4d29a8bfc6cda04eb5b0d3c460751c2402c5c5cc9109c` |
| Withdrawal | `7fcf532c15f0a6db0bd6d0e038bea71d30d808c7d98cb3bf7268a95bf5081b65` |