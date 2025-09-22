.PHONY: build clean proto

# Build all packages for WASM target
build:
	cargo build --release --target wasm32-unknown-unknown

# Clean build artifacts
clean:
	cargo clean

# Build only the proto package
proto:
	cd proto && cargo build

# Check all packages compile
check:
	cargo check

# Format code
fmt:
	cargo fmt

# Build specific package
build-tron-blocks:
	cd tron-blocks && cargo build --release --target wasm32-unknown-unknown

# Package the substreams
package:
	cd tron-blocks && substreams pack substreams.yaml