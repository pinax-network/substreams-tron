# ClickHouse TRON Tokens

Substreams for tracking Token transfers for both Native & TRC-20 on the TRON blockchain with ClickHouse database schema templates.

## Features

- **TRC-20 Transfers**: Processes TRC-20 token transfer events from logs
- **Native Transfers**: Processes native TRX transfers from transactions
- **SQL Templates**: Provides ClickHouse table schemas for logs and transactions
- **Database Changes**: Outputs database change events for streaming to ClickHouse

## Tables

### `trc20_transfer`
Stores TRC-20 token transfer events extracted from transaction logs.

**Columns:**
- Block information: `block_num`, `block_hash`, `timestamp`
- Transaction info: `transaction_hash`, `transaction_from`, `transaction_to`, etc.
- Log info: `log_address`, `log_ordinal`
- Transfer info: `transfer_from`, `transfer_to`, `transfer_amount`

### `native_transfer`
Stores native TRX transfer events extracted from transactions.

**Columns:**
- Block information: `block_num`, `block_hash`, `timestamp`
- Transaction info: `transaction_hash`, `transaction_from`, `transaction_to`, etc.
- Transfer info: `transfer_from`, `transfer_to`, `transfer_amount`

## Build

```bash
make build
```

## Usage

This substreams module processes TRON transfers data and outputs ClickHouse database changes that can be consumed by database sinks.

The generated `schema.sql` file contains all table definitions for setting up the ClickHouse database.