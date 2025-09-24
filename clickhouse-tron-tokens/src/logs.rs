use proto::pb::tron::transfers::v1 as pb;
use substreams::pb::substreams::Clock;
use substreams_database_change::tables::Tables;

use crate::{set_clock, transactions::set_template_tx};

pub fn process_events(tables: &mut Tables, clock: &Clock, events: &pb::Events) {
    for (tx_index, tx) in events.transactions.iter().enumerate() {
        for (log_index, log) in tx.logs.iter().enumerate() {
            if let Some(pb::log::Log::Transfer(transfer)) = &log.log {
                let key = log_key(clock, tx_index, log_index);
                let row = tables.create_row("trc20_transfer", key);

                // TEMPLATE
                set_clock(clock, row);
                set_template_log(log, log_index, row);
                set_template_tx(tx, tx_index, row);

                // Transfer
                row.set("from", hex::encode(&transfer.from));
                row.set("to", hex::encode(&transfer.to));
                row.set("amount", &transfer.amount);
            }
        }
    }
}

pub fn log_key(clock: &Clock, tx_index: usize, log_index: usize) -> [(&'static str, String); 5] {
    let seconds = clock.timestamp.as_ref().expect("clock.timestamp is required").seconds;
    [
        ("timestamp", seconds.to_string()),
        ("block_num", clock.number.to_string()),
        ("block_hash", clock.id.to_string()),
        ("tx_index", tx_index.to_string()),
        ("log_index", log_index.to_string()),
    ]
}

fn set_template_log(log: &pb::Log, log_index: usize, row: &mut substreams_database_change::tables::Row) {
    row.set("log_index", log_index as u32);
    row.set("log_address", hex::encode(&log.address));
    row.set("log_ordinal", log.ordinal);
}
