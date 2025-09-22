# Substreams Tron Development Instructions

Always reference these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.

## Project Overview

This is a **Substreams** project for the **Tron** blockchain. Substreams is a powerful blockchain data streaming framework that allows real-time and historical data processing. This repository provides data extraction and transformation capabilities for Tron blockchain data.

The project uses:
- **Rust** for WASM module development  
- **Protocol Buffers** for data definitions
- **Substreams CLI** for build, packaging, and deployment
- **WASM compilation** for high-performance streaming modules

## Essential Setup Commands - ALWAYS RUN THESE FIRST

**CRITICAL: Follow these commands exactly. These steps are required before any development work.**

### 1. Install Core Dependencies

```bash
# Install protobuf compiler (required for substreams)
sudo apt-get update && sudo apt-get install -y protobuf-compiler

# Add WASM compilation target for Rust  
rustup target add wasm32-unknown-unknown

# Install substreams CLI v1.9.0
cd /tmp
wget https://github.com/streamingfast/substreams/releases/download/v1.9.0/substreams_linux_x86_64.tar.gz
tar -xzf substreams_linux_x86_64.tar.gz
sudo mv substreams /usr/local/bin/

# Verify installations
protoc --version        # Should show: libprotoc 3.21.12
rustc --version         # Should show: rustc 1.89.0 or similar
cargo --version         # Should show: cargo 1.89.0 or similar  
substreams --version    # Should show: substreams version 1.9.0
```

### 2. Core Development Workflow

```bash
# Validate project structure
substreams info .

# Check Rust code for errors (fast)
cargo check                                    # Takes ~8 seconds first time, <1 second after

# Build WASM module (required for packaging)
cargo build --target wasm32-unknown-unknown --release    # Takes ~13 seconds. NEVER CANCEL.

# Package substreams for distribution  
substreams pack .                              # Takes <1 second

# Format code
cargo fmt

# Lint code  
cargo clippy

# Run tests
cargo test                                     # Takes ~6 seconds
```

## Build Times and Critical Warnings

**⚠️ NEVER CANCEL BUILDS OR COMMANDS:**
- **WASM build**: Takes ~13 seconds. Set timeout to 60+ seconds minimum.
- **Cargo test**: Takes ~6 seconds. Set timeout to 30+ seconds minimum.
- **Initial dependency download**: Takes ~25 seconds first time. Set timeout to 120+ seconds.
- **Cargo check (first time)**: Takes ~8 seconds. Subsequent runs <1 second.

**Always wait for all commands to complete fully.**

## Project Structure

```
/
├── .github/
│   └── copilot-instructions.md     # This file
├── src/
│   └── lib.rs                      # Main Rust source code for substreams modules
├── proto/                          # Protocol buffer definitions (when needed)  
├── target/                         # Rust build artifacts (gitignored)
├── Cargo.toml                      # Rust dependencies and build configuration
├── substreams.yaml                 # Substreams package manifest
├── README.md                       # Project documentation
└── *.spkg                         # Generated substreams packages (after pack)
```

## Key Files

### `substreams.yaml`
The main configuration file defining:
- Package metadata (name, version)
- Module definitions and data flow
- Input/output specifications  
- Binary locations

### `Cargo.toml`
Rust project configuration with required dependencies:
- `substreams = "0.6"` - Core substreams runtime
- `prost = "0.13"` - Protocol buffer support
- `prost-types = "0.13"` - Protocol buffer type definitions

### `src/lib.rs`
Contains the substreams module handlers using the `#[substreams::handlers::map]` or `#[substreams::handlers::store]` macros.

## Common Development Tasks

### Creating New Modules
1. Add module handler to `src/lib.rs`
2. Update `substreams.yaml` with module definition
3. Build WASM: `cargo build --target wasm32-unknown-unknown --release`
4. Test: `substreams info .`
5. Package: `substreams pack .`

### Testing Changes
Always run this validation sequence after making changes:
```bash
cargo check                                           # Verify Rust compilation
cargo build --target wasm32-unknown-unknown --release    # Build WASM (NEVER CANCEL - 13 seconds)
substreams info .                                     # Verify substreams package structure  
substreams pack .                                     # Create package file
cargo fmt && cargo clippy                             # Format and lint
cargo test                                            # Run tests (NEVER CANCEL - 6 seconds)
```

### Viewing Project Information
```bash
substreams info .              # Show modules, inputs, outputs
substreams graph .             # Generate Mermaid dependency graph  
ls -la *.spkg                 # List generated packages
```

## Validation and Quality Checks

**Always run before committing:**
```bash
cargo fmt --check             # Verify formatting (fails if not formatted)
cargo clippy                  # Check for common mistakes and improvements  
cargo test                    # Run all tests (NEVER CANCEL - 6 seconds)
```

**Fix formatting issues:**
```bash
cargo fmt                     # Auto-format all Rust code
```

## Debugging and Troubleshooting

### Common Issues

**"failed to resolve: could not find `tron` in `pb`"**
- Missing or incorrect protocol buffer definitions
- Check imports in `substreams.yaml` 
- Verify proto definitions exist

**"open substreams.yaml: no such file or directory"**  
- Run commands from repository root
- Verify `substreams.yaml` exists

**"unable to read file ... target/.../substreams_tron.wasm"**
- Build WASM first: `cargo build --target wasm32-unknown-unknown --release`

**Network/download errors during dependency resolution**
- Wait and retry - network issues are common
- Dependencies download once then cache locally

### Getting Help
```bash
substreams --help              # Main CLI help
substreams <command> --help    # Command-specific help  
cargo --help                   # Rust toolchain help
```

## Development Environment Notes

- **Rust Version**: 1.89.0 (confirmed working)
- **Substreams CLI**: v1.9.0 (confirmed working)  
- **Protobuf**: 3.21.12 (confirmed working)
- **Build Target**: wasm32-unknown-unknown (required for substreams)

The development environment is Linux x86_64 (Ubuntu 24.04) with all required tools available via package managers.

## Example Commands Reference

```bash
# Complete build and validation workflow
cargo check && \
cargo build --target wasm32-unknown-unknown --release && \
substreams info . && \
substreams pack . && \
cargo fmt && cargo clippy && cargo test

# Quick development cycle (after initial build)
cargo check                    # Fast syntax/type checking
substreams info .              # Verify package structure

# View generated artifacts  
ls -la target/wasm32-unknown-unknown/release/*.wasm    # WASM binaries
ls -la *.spkg                                         # Substreams packages

# Clean build artifacts
cargo clean                    # Remove all build artifacts
```

**Remember: Always build WASM target for substreams functionality, and never cancel builds even if they seem slow.**