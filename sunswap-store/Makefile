ENDPOINT ?= tronevm.substreams.pinax.network:443
# ENDPOINT ?= mainnet-evm.tron.streamingfast.io:443
START_BLOCK ?= 1000000
PARALLEL_JOBS ?= 500

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release

.PHONY: pack
pack: build
	substreams pack

.PHONY: noop
noop: build
	substreams-sink-noop $(ENDPOINT) substreams.yaml map_events -H "X-Substreams-Parallel-Workers: $(PARALLEL_JOBS)" $(START_BLOCK):

.PHONY: gui
gui: build
	substreams gui -e $(ENDPOINT) substreams.yaml store_pair_created -s $(START_BLOCK) -t 0 --limit-processed-blocks 0 -H "X-Substreams-Parallel-Workers: $(PARALLEL_JOBS)"  --production-mode

.PHONY: prod
prod: build
	substreams gui -e $(ENDPOINT) substreams.yaml map_events -s $(START_BLOCK) -t 0 --limit-processed-blocks 0 --production-mode  -H "X-Substreams-Parallel-Workers: $(PARALLEL_JOBS)"


# X-Sf-Substreams-Parallel-Jobs