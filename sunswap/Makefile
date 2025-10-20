ENDPOINT ?= tronevm.substreams.pinax.network:443
# ENDPOINT ?= mainnet-evm.tron.streamingfast.io:443
START_BLOCK ?= 70027397
STOP_BLOCK ?= 70037397
PARALLEL_JOBS ?= 500

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release

.PHONY: pack
pack: build
	substreams pack

.PHONY: noop
noop: build
	substreams-sink-noop $(ENDPOINT) substreams.yaml map_events -H "X-Substreams-Parallel-Workers: $(PARALLEL_JOBS)" :

.PHONY: gui
gui: build
	substreams gui -e $(ENDPOINT) substreams.yaml map_events -s $(START_BLOCK) --limit-processed-blocks 0

.PHONY: prod
prod: build
	substreams gui -e $(ENDPOINT) substreams.yaml map_events -s $(START_BLOCK) -t $(STOP_BLOCK) --limit-processed-blocks 0 --production-mode  -H "X-Substreams-Parallel-Workers: $(PARALLEL_JOBS)"


# X-Sf-Substreams-Parallel-Jobs