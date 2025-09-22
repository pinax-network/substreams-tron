# Substreams TRON

**ALWAYS follow these instructions first and fallback to search or bash commands only when you encounter unexpected information that does not match the info here.**

Substreams TRON is a Rust-based library for processing TRON blockchain data using the Substreams framework. It provides WASM modules for real-time blockchain data extraction and transformation on the TRON network.

## Working Effectively

### Environment Setup
- Ensure Rust toolchain is available: `rustc 1.89.0` and `cargo 1.89.0` are confirmed working
- Add WASM target: `rustup target add wasm32-unknown-unknown`
- **NEVER CANCEL**: Target installation takes 1-2 minutes. Set timeout to 5+ minutes.

### Build Commands (VALIDATED - all commands work)
- **Development check**: `cargo check` -- takes 5-10 seconds after dependencies are cached
- **Development build**: `cargo build` -- takes 5-8 seconds after initial compile
- **Release build**: `cargo build --release` -- takes 12-15 seconds. **NEVER CANCEL**: Set timeout to 30+ minutes for first build with all dependencies.
- **WASM build** (CRITICAL): `cargo build --target wasm32-unknown-unknown --release` -- takes 8-10 seconds after dependencies cached. **NEVER CANCEL**: Set timeout to 20+ minutes for first build.

### Initial Build Timing (MEASURED)
- **First-time dependency download and compilation**: 30-35 seconds for `cargo check`
- **First full build**: 5 seconds (after deps cached)
- **First release build**: 12 seconds (after deps cached)  
- **First WASM build**: 8 seconds (after deps cached)
- **CRITICAL**: Always allow 60+ minutes timeout for any first build to account for dependency compilation

### Testing
- **Run tests**: `cargo test` -- takes 1-2 seconds. **NEVER CANCEL**: Set timeout to 10+ minutes.
- All tests pass in current codebase

### Linting and Formatting
- **Linting**: `cargo clippy` -- takes 1-2 seconds after initial compile
- **Format check**: `cargo fmt --check` -- takes <1 second  
- **Format code**: `cargo fmt` -- takes <1 second
- **ALWAYS run these before committing** or CI will fail

### Key Files and Structure
```
├── Cargo.toml              # Rust project configuration
├── Cargo.lock              # Dependency lock file (auto-generated)
├── src/
│   └── lib.rs              # Main library code
├── substreams.yaml         # Substreams module configuration
├── target/                 # Build artifacts (gitignored)
│   └── wasm32-unknown-unknown/release/
│       └── substreams_tron.wasm  # Generated WASM module
├── .gitignore              # Rust-specific gitignore
├── LICENSE                 # Apache 2.0 license
└── README.md               # Project documentation
```

## Development Workflow

### Building Changes
1. **Quick validation**: `cargo check` (5-10 seconds)
2. **Full test**: `cargo test` (1-2 seconds) 
3. **WASM build**: `cargo build --target wasm32-unknown-unknown --release` (8-10 seconds)
4. **Linting**: `cargo clippy` and `cargo fmt --check`

### Making Code Changes
- Edit `src/lib.rs` for the main library code
- Update `Cargo.toml` for dependencies
- Update `substreams.yaml` for module configuration
- The project builds a WASM library (`cdylib`) for use with Substreams

### Substreams-Specific Notes
- This project generates WASM modules for blockchain data processing
- The main output is `target/wasm32-unknown-unknown/release/substreams_tron.wasm`
- Uses `substreams = "0.6.2"` crate for the framework
- Configuration in `substreams.yaml` defines module inputs/outputs
- **No substreams CLI tool available in this environment** - cannot run `substreams` commands

## Validation Scenarios

### After Making Changes - ALWAYS Test These
1. **Code compiles**: `cargo check` 
2. **Tests pass**: `cargo test`
3. **WASM builds successfully**: `cargo build --target wasm32-unknown-unknown --release`
4. **Linting passes**: `cargo clippy`
5. **Formatting is correct**: `cargo fmt --check`
6. **Verify WASM file exists**: `ls target/wasm32-unknown-unknown/release/substreams_tron.wasm`

### Complete Development Cycle Test
```bash
# Start from clean state
cargo clean

# Build everything with timing
time cargo build --release  # Should complete in 12-15 seconds after deps
time cargo test             # Should complete in 1-2 seconds  
time cargo build --target wasm32-unknown-unknown --release  # Should complete in 8-10 seconds

# Verify outputs
file target/wasm32-unknown-unknown/release/substreams_tron.wasm  # Should show "WebAssembly (wasm) binary"
```

## Common Commands (VALIDATED)

### Quick Development Loop
```bash
cargo check && cargo test && cargo clippy
```

### Full Build and Validation  
```bash
cargo build --release && cargo build --target wasm32-unknown-unknown --release && cargo test && cargo clippy && cargo fmt --check
```

### Clean Build (when needed)
```bash
cargo clean && cargo build --target wasm32-unknown-unknown --release
```

## Troubleshooting

### Build Issues
- If builds fail, check `Cargo.toml` dependencies
- Ensure `wasm32-unknown-unknown` target is installed: `rustup target add wasm32-unknown-unknown`
- Clean build if needed: `cargo clean`

### Dependency Issues  
- All dependencies download from crates.io
- **NEVER CANCEL**: First dependency download can take 5+ minutes
- Cached builds are much faster (seconds)

### WASM Build Requirements
- Must have `crate-type = ["cdylib"]` in `Cargo.toml`
- Build target: `wasm32-unknown-unknown`
- Output: `.wasm` file in release directory

## Repository Information

### Project State
- Basic Rust library project with Substreams dependencies
- Configured for WASM compilation
- Ready for TRON blockchain data processing development
- All build commands validated and working

### Git Workflow  
- Work on feature branches
- Always run full validation before committing
- Use `cargo fmt` before committing to ensure formatting

**REMEMBER**: This environment has limited network access, so the substreams CLI tools cannot be installed, but all Rust/Cargo functionality works perfectly.