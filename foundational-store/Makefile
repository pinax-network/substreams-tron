ENDPOINT ?= tronevm.substreams.pinax.network:443
# ENDPOINT ?= mainnet-evm.tron.streamingfast.io:443
START_BLOCK ?= 70027397
PARALLEL_JOBS ?= 500

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release

.PHONY: pack
pack: build
	substreams pack

.PHONY: noop
noop: build
	substreams-sink-noop $(ENDPOINT) substreams.yaml foundational_store -H "X-Substreams-Parallel-Workers: $(PARALLEL_JOBS)" :

.PHONY: gui
gui: build
	substreams gui -e $(ENDPOINT) substreams.yaml foundational_store -s $(START_BLOCK) -t +1000 --limit-processed-blocks 0

.PHONY: prod
prod: build
	substreams gui -e $(ENDPOINT) substreams.yaml foundational_store -s $(START_BLOCK) -t 0 --limit-processed-blocks 0 --production-mode  -H "X-Substreams-Parallel-Workers: $(PARALLEL_JOBS)"

.PHONY: store
store:
	foundational-store server \
		--dsn=badger://$(HOME)/.local/share/foundational-store \
		--type-url=tron.foundational_store.v1.PairCreated \
		--manifest-path=substreams.yaml \
		--output-module-name=foundational_store \
		--endpoint=tronevm.substreams.pinax.network:443 \
		--start-block=$(START_BLOCK)
