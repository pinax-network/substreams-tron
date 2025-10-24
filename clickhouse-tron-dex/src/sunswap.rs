use common::tron_base58_from_bytes;
use proto::pb::tron::foundational_store::v1::PairCreated;
use proto::pb::tron::sunswap;
// use substreams::store::FoundationalStore;
use substreams::{pb::substreams::Clock, store::StoreGetProto};
use substreams_database_change::tables::Tables;

use crate::{
    foundational_stores::get_pair_created,
    logs::{log_key, set_template_log},
    set_clock,
    transactions::set_template_tx,
};

// SunSwap Processing
pub fn process_events(
    tables: &mut Tables,
    clock: &Clock,
    events: &sunswap::v1::Events,
    store: &StoreGetProto<PairCreated>,
    // store_foundational: &FoundationalStore,
) {
    for (tx_index, tx) in events.transactions.iter().enumerate() {
        for (log_index, log) in tx.logs.iter().enumerate() {
            match &log.log {
                Some(sunswap::v1::log::Log::Swap(swap)) => {
                    process_sunswap_swap(store, tables, clock, tx, log, tx_index, log_index, swap);
                }
                Some(sunswap::v1::log::Log::PairCreated(pair_created)) => {
                    process_sunswap_pair_created(tables, clock, tx, log, tx_index, log_index, pair_created);
                }
                Some(sunswap::v1::log::Log::Mint(event)) => {
                    process_sunswap_mint(store, tables, clock, tx, log, tx_index, log_index, event);
                }
                Some(sunswap::v1::log::Log::Burn(event)) => {
                    process_sunswap_burn(store, tables, clock, tx, log, tx_index, log_index, event);
                }
                Some(sunswap::v1::log::Log::Sync(event)) => {
                    process_sunswap_sync(store, tables, clock, tx, log, tx_index, log_index, event);
                }
                _ => {} // Ignore other event types
            }
        }
    }
}

pub fn set_pair_created(value: Option<PairCreated>, row: &mut substreams_database_change::tables::Row) {
    if let Some(value) = value {
        row.set("factory", tron_base58_from_bytes(&value.factory).unwrap());
        row.set("token0", tron_base58_from_bytes(&value.token0).unwrap());
        row.set("token1", tron_base58_from_bytes(&value.token1).unwrap());
        substreams::log::info!(
            "PairCreated found: factory={}, token0={}, token1={}",
            tron_base58_from_bytes(&value.factory).unwrap(),
            tron_base58_from_bytes(&value.token0).unwrap(),
            tron_base58_from_bytes(&value.token1).unwrap(),
        );
    } else {
        row.set("factory", "");
        row.set("token0", "");
        row.set("token1", "");
        substreams::log::info!("PairCreated not found");
    }
}

fn process_sunswap_swap(
    // store: &FoundationalStore,
    store: &StoreGetProto<PairCreated>,
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunswap::v1::Transaction,
    log: &sunswap::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunswap::v1::Swap,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunswap_swap", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Set PairCreated event data
    set_pair_created(get_pair_created(store, &log.address), row);

    // Swap info
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

fn process_sunswap_mint(
    // store: &FoundationalStore,
    store: &StoreGetProto<PairCreated>,
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunswap::v1::Transaction,
    log: &sunswap::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunswap::v1::Mint,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunswap_mint", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Set PairCreated event data
    set_pair_created(get_pair_created(store, &log.address), row);

    // Event info
    row.set("sender", tron_base58_from_bytes(&event.sender).unwrap());
    row.set("amount0", &event.amount0);
    row.set("amount1", &event.amount1);
}

fn process_sunswap_burn(
    // store: &FoundationalStore,
    store: &StoreGetProto<PairCreated>,
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunswap::v1::Transaction,
    log: &sunswap::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunswap::v1::Burn,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunswap_burn", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Set PairCreated event data
    set_pair_created(get_pair_created(store, &log.address), row);

    // Event info
    row.set("sender", tron_base58_from_bytes(&event.sender).unwrap());
    row.set("amount0", &event.amount0);
    row.set("amount1", &event.amount1);
    row.set("to", tron_base58_from_bytes(&event.to).unwrap());
}

fn process_sunswap_sync(
    // store: &FoundationalStore,
    store: &StoreGetProto<PairCreated>,
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunswap::v1::Transaction,
    log: &sunswap::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunswap::v1::Sync,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunswap_sync", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Set PairCreated event data
    set_pair_created(get_pair_created(store, &log.address), row);

    // Event info
    row.set("reserve0", &event.reserve0);
    row.set("reserve1", &event.reserve1);
}
