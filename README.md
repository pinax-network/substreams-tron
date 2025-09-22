# substreams-tron

A minimal scaffold for building [Substreams](https://substreams.streamingfast.io) modules on top of the Tron blockchain.

## Getting started

This repository ships with a single Rust crate that compiles protobuf definitions from the
[Firehose Tron](https://github.com/streamingfast/firehose-tron) project. It is intended to be a starting
point for Tron Substreams development.

```bash
cargo build
```

## Protobuf definitions

The protobuf definitions are vendored under `proto/` to ease builds without relying on external
repositories. The main block type is available in the crate at `pb::sf::tron::r#type::v1`.
