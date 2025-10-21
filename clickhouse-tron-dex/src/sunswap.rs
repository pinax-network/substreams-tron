use common::tron_base58_from_bytes;
use proto::pb::tron::foundational_store::v1::PairCreated;
use proto::pb::tron::sunswap;
use substreams::pb::substreams::Clock;
use substreams::store::{StoreGet, StoreGetProto};
use substreams::Hex;
use substreams_database_change::tables::Tables;

use crate::{
    logs::{log_key, set_template_log},
    set_clock,
    transactions::set_template_tx,
};

// SunSwap Processing
pub fn process_events(tables: &mut Tables, clock: &Clock, events: &sunswap::v1::Events, store: &StoreGetProto<PairCreated>) {
    for (tx_index, tx) in events.transactions.iter().enumerate() {
        for (log_index, log) in tx.logs.iter().enumerate() {
            if let Some(sunswap::v1::log::Log::Swap(swap)) = &log.log {
                process_sunswap_swap(store, tables, clock, tx, log, tx_index, log_index, swap);
            }
            if let Some(sunswap::v1::log::Log::PairCreated(pair_created)) = &log.log {
                process_sunswap_pair_created(tables, clock, tx, log, tx_index, log_index, pair_created);
            }
        }
    }
}

fn process_sunswap_swap(
    store: &StoreGetProto<PairCreated>,
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunswap::v1::Transaction,
    log: &sunswap::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunswap::v1::Swap,
) {
    // Swap must have a corresponding PairCreated event
    let pair_created = store.get_first(Hex::encode(log.address.to_vec()));
    if pair_created.is_none() {
        substreams::log::info!("PairCreated not found in store for address: {}", tron_base58_from_bytes(&log.address).unwrap());
        return;
    }

    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunswap_swap", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Get PairCreated
    if let Some(value) = &pair_created {
        row.set("token0", tron_base58_from_bytes(&value.token0).unwrap());
        row.set("token1", tron_base58_from_bytes(&value.token1).unwrap());
        row.set("factory", tron_base58_from_bytes(&value.factory).unwrap());
        substreams::log::info!(
            "PairCreated found for address: {}, token0: {}, token1: {}",
            tron_base58_from_bytes(&log.address).unwrap(),
            tron_base58_from_bytes(&value.token0).unwrap(),
            tron_base58_from_bytes(&value.token1).unwrap()
        );
    } else {
        row.set("token0", "");
        row.set("token1", "");
        row.set("factory", "");
        substreams::log::info!("PairCreated not found for address: {}", tron_base58_from_bytes(&log.address).unwrap());
        panic!("PairCreated not found for address: {}", tron_base58_from_bytes(&log.address).unwrap());
    }

    // Swap info
    row.set("pair", tron_base58_from_bytes(&log.address).unwrap());
    row.set("sender", tron_base58_from_bytes(&event.sender).unwrap());
    row.set("to", tron_base58_from_bytes(&event.to).unwrap());
    row.set("amount0_in", &event.amount0_in);
    row.set("amount1_in", &event.amount1_in);
    row.set("amount0_out", &event.amount0_out);
    row.set("amount1_out", &event.amount1_out);
}

fn process_sunswap_pair_created(
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunswap::v1::Transaction,
    log: &sunswap::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunswap::v1::PairCreated,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunswap_pair_created", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Pair Created info
    row.set("token0", tron_base58_from_bytes(&event.token0).unwrap());
    row.set("token1", tron_base58_from_bytes(&event.token1).unwrap());
    row.set("pair", tron_base58_from_bytes(&event.pair).unwrap());
}
