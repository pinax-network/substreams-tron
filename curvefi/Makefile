.PHONY: all build pack clean

all: build

build:
	cargo build --target wasm32-unknown-unknown --release

pack: build
	substreams pack substreams.yaml

clean:
	cargo clean
