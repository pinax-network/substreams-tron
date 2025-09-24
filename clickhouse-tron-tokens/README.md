# Tron Tokens: ClickHouse

This crate exposes a Substreams map module that converts Tron token transfer events into `DatabaseChanges`
compatible with the [`substreams-sink-sql`](https://github.com/streamingfast/substreams-sink-sql) service.

Two ClickHouse schemas are provided:

- `sql/trc20_transfers.sql` creates a table for TRC20 transfers extracted from EVM logs.
- `sql/native_transfers.sql` creates a table for native TRX transfers derived from transaction values.

The `db_out` map consumes the output of the [`transfers`](../transfers) package and produces rows for the
corresponding tables.
