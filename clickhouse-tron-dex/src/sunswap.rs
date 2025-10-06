use common::tron_base58_from_bytes;
use proto::pb::tron::sunswap;
use substreams::pb::substreams::Clock;
use substreams_database_change::tables::Tables;

use crate::{
    logs::{log_key, set_template_log},
    set_clock,
    transactions::set_template_tx,
};

// SunSwap Processing
pub fn process_events(tables: &mut Tables, clock: &Clock, events: &sunswap::v1::Events) {
    for (tx_index, tx) in events.transactions.iter().enumerate() {
        for (log_index, log) in tx.logs.iter().enumerate() {
            if let Some(sunswap::v1::log::Log::Swap(swap)) = &log.log {
                process_sunswap_swap(tables, clock, tx, log, tx_index, log_index, swap);
            }
        }
    }
}

fn process_sunswap_swap(
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunswap::v1::Transaction,
    log: &sunswap::v1::Log,
    tx_index: usize,
    log_index: usize,
    swap: &sunswap::v1::Swap,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunswap_swap", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Swap info
    row.set("sender", tron_base58_from_bytes(&swap.sender).unwrap());
    row.set("to", tron_base58_from_bytes(&swap.to).unwrap());
    row.set("amount0_in", &swap.amount0_in);
    row.set("amount1_in", &swap.amount1_in);
    row.set("amount0_out", &swap.amount0_out);
    row.set("amount1_out", &swap.amount1_out);
}
