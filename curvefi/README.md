# CurveFi Substreams

Substreams module for extracting CurveFi Pool events from TRON blockchain.

## Events

This module tracks the following CurveFi Pool events based on the latest ABI:

- **TokenExchange**: Token swap events in CurveFi pools
- **AddLiquidity**: Liquidity additions to pools
- **RemoveLiquidity**: Full liquidity removals
- **RemoveLiquidityOne**: Single-sided liquidity removals
- **RemoveLiquidityImbalance**: Imbalanced liquidity removals
- **CommitNewAdmin**: Admin change proposals
- **NewAdmin**: Admin changes
- **CommitNewFee**: Fee change proposals
- **NewFee**: Fee changes
- **RampA**: Amplification parameter changes
- **StopRampA**: Amplification parameter change stops

## Store

The module includes `store.rs` which provides store handlers for tracking:
- Pool information (pool address, provider, total liquidity)

## Building

```bash
make build
```

## Usage

```bash
substreams pack substreams.yaml
```
