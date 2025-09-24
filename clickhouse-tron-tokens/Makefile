ENDPOINT ?= mainnet-evm.tron.streamingfast.io:443
START_BLOCK ?= 75998281
PARALLEL_JOBS ?= 500

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release

.PHONY: pack
pack: build
	substreams pack

.PHONY: sink
sink: build
	substreams-sink-sql $(ENDPOINT) substreams.yaml db_out -H "X-Sf-Substreams-Parallel-Jobs: $(PARALLEL_JOBS)" $(START_BLOCK):
