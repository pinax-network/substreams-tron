ENDPOINT ?= tronevm.substreams.pinax.network:443
# ENDPOINT ?= mainnet-evm.tron.streamingfast.io:443
START_BLOCK ?= 1
PARALLEL_JOBS ?= 5000

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release

.PHONY: pack
pack: build
	substreams pack

.PHONY: noop
noop: build
	substreams-sink-noop $(ENDPOINT) substreams.yaml foundational_store -H "X-Substreams-Parallel-Workers: $(PARALLEL_JOBS)" $(START_BLOCK):

.PHONY: gui
gui: build
	substreams gui -e $(ENDPOINT) substreams.yaml foundational_store -s $(START_BLOCK) -t 0 --limit-processed-blocks 0 -H "X-Substreams-Parallel-Workers: $(PARALLEL_JOBS)" --production-mode

.PHONY: prod
prod: build
	substreams gui -e $(ENDPOINT) substreams.yaml foundational_store -s $(START_BLOCK) -t 0 --limit-processed-blocks 0 --production-mode  -H "X-Substreams-Parallel-Workers: $(PARALLEL_JOBS)"


# X-Sf-Substreams-Parallel-Jobs