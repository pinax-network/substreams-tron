use proto::pb::tron::transfers::v1 as pb;
use substreams::pb::substreams::Clock;
use substreams_database_change::tables::Tables;

pub fn process_events(tables: &mut Tables, clock: &Clock, events: &pb::Events) {
    for transaction in &events.transactions {
        // Only process transactions with native value transfers (value > 0)
        if transaction.value != "0" && !transaction.value.is_empty() {
            let row = tables.create_row("native_transfer", [("transaction_hash", hex::encode(&transaction.hash))]);

            // Block information
            set_block_info(clock, row);

            // Transaction information
            row.set("transaction_from", hex::encode(&transaction.from));
            row.set("transaction_to", hex::encode(&transaction.to));
            row.set("transaction_nonce", transaction.nonce);
            row.set("transaction_gas_price", &transaction.gas_price);
            row.set("transaction_gas_limit", transaction.gas_limit);
            row.set("transaction_gas_used", transaction.gas_used);
            row.set("transaction_value", &transaction.value);

            // Transfer information (for native transfers, from/to are same as transaction from/to)
            row.set("transfer_from", hex::encode(&transaction.from));
            row.set("transfer_to", hex::encode(&transaction.to));
            row.set("transfer_amount", &transaction.value);
        }
    }
}

fn set_block_info(clock: &Clock, row: &mut substreams_database_change::tables::Row) {
    row.set("block_num", clock.number);
    row.set("block_hash", &clock.id);
    if let Some(timestamp) = &clock.timestamp {
        row.set("timestamp", timestamp.seconds);
    }
}
