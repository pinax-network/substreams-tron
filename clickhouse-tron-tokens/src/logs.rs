use proto::pb::tron::transfers::v1 as pb;
use substreams::pb::substreams::Clock;
use substreams_database_change::tables::Tables;

pub fn process_events(tables: &mut Tables, clock: &Clock, events: &pb::Events) {
    for transaction in &events.transactions {
        for log in &transaction.logs {
            if let Some(pb::log::Log::Transfer(transfer)) = &log.log {
                let row = tables.create_row("trc20_transfer", [("transaction_hash", hex::encode(&transaction.hash))]);

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

                // Log information
                row.set("log_address", hex::encode(&log.address));
                row.set("log_ordinal", log.ordinal);

                // Transfer event information
                row.set("transfer_from", hex::encode(&transfer.from));
                row.set("transfer_to", hex::encode(&transfer.to));
                row.set("transfer_amount", &transfer.amount);
            }
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
