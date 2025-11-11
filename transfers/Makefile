ENDPOINT ?= tronevm.substreams.pinax.network:443
# ENDPOINT ?= tronevm-sf-substreams-tier1-v1.riv-sst2.pinax.io:443
START_BLOCK ?= 70000000
PARALLEL_JOBS ?= 500

.PHONY: build
build:
	cargo build --target wasm32-unknown-unknown --release

.PHONY: pack
pack: build
	substreams pack

.PHONY: noop
noop: build
	substreams-sink-noop $(ENDPOINT) substreams.yaml map_events -H "X-Sf-Substreams-Parallel-Jobs: $(PARALLEL_JOBS)" 0:

.PHONY: gui
gui: build
	substreams gui -e $(ENDPOINT) substreams.yaml map_events -s $(START_BLOCK) --limit-processed-blocks 0

.PHONY: prod
prod: build
	substreams gui -e $(ENDPOINT) substreams.yaml map_events -s $(START_BLOCK) -t 0 --limit-processed-blocks 0 --production-mode  -H "X-Sf-Substreams-Parallel-Jobs: $(PARALLEL_JOBS)"