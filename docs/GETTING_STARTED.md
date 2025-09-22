# Getting Started

This repository provides a scaffold for building Substreams on the Tron blockchain.

## Structure

- `proto/` - Protocol buffer definitions for Tron block types
- `common/` - Shared utilities and helper functions
- `tron-blocks/` - Example substream for processing Tron blocks

## Building

### Prerequisites

- [Rust](https://www.rust-lang.org/tools/install) (1.85+)
- [protobuf compiler](https://grpc.io/docs/protoc-installation/)

### Build Commands

```bash
# Check all packages compile
make check

# Build all packages
make build

# Build specific package
make build-tron-blocks

# Format code
make fmt
```

### Running the Example

```bash
cd tron-blocks

# Build the WASM binary
cargo build --release --target wasm32-unknown-unknown

# Package the substream (requires substreams CLI)
substreams pack substreams.yaml

# Run against a Tron endpoint (requires actual Tron data source)
# substreams run substreams.yaml map_blocks -e <tron-endpoint> -s 66000000 -t +10
```

## Extending

To create a new substream:

1. Create a new crate in the workspace
2. Add it to the root `Cargo.toml` members list
3. Use `substreams-tron-proto` for Tron block types
4. Use `substreams-tron-common` for utility functions
5. Implement your map/store handlers using the `#[substreams::handlers::map]` attribute

### Example New Crate

```toml
# your-new-crate/Cargo.toml
[package]
name = "your-new-crate"
description.workspace = true
version.workspace = true
edition.workspace = true
license.workspace = true

[dependencies]
substreams.workspace = true
substreams-tron-proto = { path = "../proto" }
substreams-tron-common = { path = "../common" }
prost.workspace = true

[lib]
crate-type = ["cdylib"]
```

```rust
// your-new-crate/src/lib.rs
use substreams_tron_proto::Block;
use substreams_tron_common::{convert_block, format_address};

#[substreams::handlers::map]
pub fn map_your_handler() -> Result<YourOutputType, substreams::errors::Error> {
    // Your logic here
    Ok(result)
}
```