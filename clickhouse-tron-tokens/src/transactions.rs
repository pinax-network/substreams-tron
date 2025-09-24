use common::tron_base58_from_bytes;
use proto::pb::tron::transfers::v1 as pb;
use substreams::pb::substreams::Clock;
use substreams_database_change::tables::Tables;

use crate::set_clock;

pub fn process_events(tables: &mut Tables, clock: &Clock, events: &pb::Events) {
    for (tx_index, transaction) in events.transactions.iter().enumerate() {
        // Only process transactions with native value transfers (value > 0)
        if transaction.value != "0" && !transaction.value.is_empty() {
            let key = tx_key(clock, tx_index);
            let row = tables.create_row("native_transfer", key);

            // TEMPLATE
            set_clock(clock, row);
            set_template_tx(transaction, tx_index, row);

            // Native Transfer
            row.set("from", tron_base58_from_bytes(&transaction.from).unwrap());
            row.set("to", tron_base58_from_bytes(&transaction.to).unwrap());
            row.set("amount", &transaction.value);
        }
    }
}

pub fn tx_key(clock: &Clock, tx_index: usize) -> [(&'static str, String); 4] {
    let seconds = clock.timestamp.as_ref().expect("clock.timestamp is required").seconds;
    [
        ("timestamp", seconds.to_string()),
        ("block_num", clock.number.to_string()),
        ("block_hash", clock.id.to_string()),
        ("tx_index", tx_index.to_string()),
    ]
}

pub fn set_template_tx(tx: &pb::Transaction, tx_index: usize, row: &mut substreams_database_change::tables::Row) {
    row.set("tx_index", tx_index as u32);
    row.set("tx_hash", hex::encode(&tx.hash));
    row.set("tx_from", tron_base58_from_bytes(&tx.from).unwrap());
    row.set("tx_to", tron_base58_from_bytes(&tx.to).unwrap());
    row.set("tx_nonce", tx.nonce);
    row.set("tx_gas_price", &tx.gas_price);
    row.set("tx_gas_limit", tx.gas_limit);
    row.set("tx_gas_used", tx.gas_used);
    row.set("tx_value", &tx.value);
}
