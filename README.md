# Tron: `Substreams`

Substreams for tracking blocks, transactions, and smart contracts on the Tron blockchain.

## Quick Start

This repository provides a scaffold for building Substreams on Tron, similar to [substreams-solana](https://github.com/pinax-network/substreams-solana).

### Prerequisites

- [Rust](https://www.rust-lang.org/tools/install) (1.85+)
- [Substreams CLI](https://substreams.streamingfast.io/getting-started/installing-the-cli)

### Building

```bash
# Build all packages
cargo build --release --target wasm32-unknown-unknown

# Or build a specific package
cd tron-blocks
cargo build --release --target wasm32-unknown-unknown
```

### Running

```bash
cd tron-blocks
substreams run substreams.yaml map_blocks -e tron.streamingfast.io:443 -s 66000000 -t +10
```

## Structure

- **`proto/`** - Protocol buffer definitions for Tron block types
- **`common/`** - Shared utilities and helper functions  
- **`tron-blocks/`** - Basic example showing how to extract block data

## Tron Block Types

This repository includes simplified protobuf definitions based on [firehose-tron](https://github.com/streamingfast/firehose-tron/blob/main/proto/sf/tron/type/v1/block.proto) for:

- `Block` - Complete block data including header and transactions
- `BlockHeader` - Block metadata (number, timestamp, witness, etc.)
- `Transaction` - Transaction data including signatures, contracts, and execution results

## Supported by Sinks

- [x] [Substreams: File Sink](https://github.com/streamingfast/substreams-sink-files) - Apache Parquet (Protobuf Map modules)
- [x] [Substreams: SQL Sink](https://github.com/streamingfast/substreams-sink-sql) - Clickhouse / PostgreSQL

## Examples

The `tron-blocks` package demonstrates:

- **`map_blocks`** - Extract complete block data with converted proto format
- **`map_transaction_count`** - Count transactions per block

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
