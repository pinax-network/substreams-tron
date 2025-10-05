# ClickHouse TRON DEX

Substreams for tracking DEX swap events from JustSwap, SunSwap, and SunPump on the TRON blockchain with ClickHouse database schema templates.

## Features

- **JustSwap Swaps**: Processes JustSwap V1 TokenPurchase and TrxPurchase events
- **SunSwap Swaps**: Processes SunSwap V2 Swap events
- **SunPump Swaps**: Processes SunPump TokenPurchased and TokenSold events
- **Unified Swaps View**: Provides materialized views combining all DEX swaps into a unified format
- **SQL Templates**: Provides ClickHouse table schemas for logs and transactions
- **Database Changes**: Outputs database change events for streaming to ClickHouse

## Tables

### `justswap_swaps`
Stores JustSwap V1 swap events (TokenPurchase and TrxPurchase).

**Columns:**
- Block information: `block_num`, `block_hash`, `timestamp`
- Transaction info: `tx_hash`, `tx_from`, `tx_to`, etc.
- Log info: `log_address`, `log_ordinal`
- Swap info: `user`, `pool`, `input_contract`, `input_amount`, `output_contract`, `output_amount`

### `sunswap_swaps`
Stores SunSwap V2 swap events.

**Columns:**
- Block information: `block_num`, `block_hash`, `timestamp`
- Transaction info: `tx_hash`, `tx_from`, `tx_to`, etc.
- Log info: `log_address`, `log_ordinal`
- Swap info: `sender`, `to`, `pool`, `input_contract`, `input_amount`, `output_contract`, `output_amount`
- Raw amounts: `amount0_in`, `amount1_in`, `amount0_out`, `amount1_out`

### `sunpump_swaps`
Stores SunPump swap events (TokenPurchased and TokenSold).

**Columns:**
- Block information: `block_num`, `block_hash`, `timestamp`
- Transaction info: `tx_hash`, `tx_from`, `tx_to`, etc.
- Log info: `log_address`, `log_ordinal`
- Swap info: `user`, `token`, `pool`, `input_contract`, `input_amount`, `output_contract`, `output_amount`, `fee`, `token_reserve`

### `swaps` (Unified View)
Materialized view combining all DEX swaps into a unified format.

**Columns:**
- Block information: `block_num`, `block_hash`, `timestamp`
- Transaction info: `tx_hash`, `tx_from`, `tx_to`, etc.
- Log info: `log_address`, `log_ordinal`
- Swap info: `dex`, `pool`, `user`, `input_contract`, `input_amount`, `output_contract`, `output_amount`

The view automatically populates from `justswap_swaps`, `sunswap_swaps`, and `sunpump_swaps` tables and filters out dust swaps (amounts <= 1).

## Build

```bash
make build
```

## Usage

This substreams module processes TRON DEX swap data and outputs ClickHouse database changes that can be consumed by database sinks.

The generated `schema.sql` file contains all table definitions for setting up the ClickHouse database.

## Development

```bash
# Build the WASM module
cargo build --target wasm32-unknown-unknown --release

# Check the code
cargo check

# Run tests
cargo test

# Format the code
cargo fmt

# Lint the code
cargo clippy
```
