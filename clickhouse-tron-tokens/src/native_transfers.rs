use common::tron_base58_from_bytes;
use proto::pb::tron::transfers::v1 as pb;
use substreams::pb::substreams::Clock;
use substreams_database_change::tables::Tables;

use crate::{
    set_clock,
    transactions::{set_template_tx, tx_key},
};

pub fn process_events(tables: &mut Tables, clock: &Clock, events: &pb::Events) {
    for (tx_index, tx) in events.transactions.iter().enumerate() {
        // Only process transactions with native value transfers (value > 0)
        if tx.value != "0" && !tx.value.is_empty() {
            let key = tx_key(clock, tx_index);
            let row = tables.create_row("native_transfer", key);

            // TEMPLATE
            set_clock(clock, row);
            set_template_tx(tx, tx_index, row);

            // from/to
            let from = tron_base58_from_bytes(&tx.from).unwrap();
            let tx_to = match &tx.to {
                Some(addr) => tron_base58_from_bytes(addr).unwrap(),
                None => "".to_string(),
            };
            // Possible reasons for None 'to' address:
            // - withdrew unstaked asset
            // - claim rewards
            // - canceled unstaking
            if tx.to.is_none() {
                row.set("from", tx_to);
                row.set("to", from);
            // Native Transfer
            } else {
                row.set("from", from);
                row.set("to", tx_to);
            }
            row.set("amount", &tx.value);
        }
    }
}
