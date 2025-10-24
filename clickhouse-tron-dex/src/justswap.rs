use common::tron_base58_from_bytes;
use proto::pb::tron::{foundational_store::v1::NewExchange, justswap};
use substreams::pb::substreams::Clock;
use substreams::store::FoundationalStore;
use substreams_database_change::tables::Tables;

use crate::{
    foundational_stores::get_new_exchange,
    logs::{log_key, set_template_log},
    set_clock,
    transactions::set_template_tx,
};

// JustSwap Processing
pub fn process_events(tables: &mut Tables, clock: &Clock, events: &justswap::v1::Events, store: &FoundationalStore) {
    for (tx_index, tx) in events.transactions.iter().enumerate() {
        for (log_index, log) in tx.logs.iter().enumerate() {
            match &log.log {
                Some(justswap::v1::log::Log::TokenPurchase(swap)) => {
                    process_justswap_token_purchase(store, tables, clock, tx, log, tx_index, log_index, swap);
                }
                Some(justswap::v1::log::Log::TrxPurchase(swap)) => {
                    process_justswap_trx_purchase(store, tables, clock, tx, log, tx_index, log_index, swap);
                }
                Some(justswap::v1::log::Log::AddLiquidity(event)) => {
                    process_justswap_add_liquidity(store, tables, clock, tx, log, tx_index, log_index, event);
                }
                Some(justswap::v1::log::Log::RemoveLiquidity(event)) => {
                    process_justswap_remove_liquidity(store, tables, clock, tx, log, tx_index, log_index, event);
                }
                Some(justswap::v1::log::Log::Snapshot(event)) => {
                    process_justswap_snapshot(store, tables, clock, tx, log, tx_index, log_index, event);
                }
                Some(justswap::v1::log::Log::NewExchange(event)) => {
                    process_justswap_new_exchange(tables, clock, tx, log, tx_index, log_index, event);
                }
                _ => {} // Ignore other event types
            }
        }
    }
}

pub fn set_new_exchange(value: Option<NewExchange>, row: &mut substreams_database_change::tables::Row) {
    if let Some(value) = value {
        row.set("factory", tron_base58_from_bytes(&value.factory).unwrap());
        row.set("token", tron_base58_from_bytes(&value.token).unwrap());
        substreams::log::info!(
            "NewExchange found: factory={}, token={}",
            tron_base58_from_bytes(&value.factory).unwrap(),
            tron_base58_from_bytes(&value.token).unwrap(),
        );
    } else {
        row.set("factory", "");
        row.set("token", "");
        substreams::log::info!("NewExchange not found");
    }
}

fn process_justswap_token_purchase(
    store: &FoundationalStore,
    // store: &StoreGetProto<NewExchange>,
    tables: &mut Tables,
    clock: &Clock,
    tx: &justswap::v1::Transaction,
    log: &justswap::v1::Log,
    tx_index: usize,
    log_index: usize,
    swap: &justswap::v1::TokenPurchase,
) {
    // Create the row and populate common fields
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("justswap_token_purchase", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Set NewExchange event data
    set_new_exchange(get_new_exchange(store, &log.address), row);

    // Swap info - TRX -> Token
    row.set("buyer", tron_base58_from_bytes(&swap.buyer).unwrap());
    row.set("trx_sold", &swap.trx_sold);
    row.set("tokens_bought", &swap.tokens_bought);
}

fn process_justswap_trx_purchase(
    store: &FoundationalStore,
    // store: &StoreGetProto<NewExchange>,
    tables: &mut Tables,
    clock: &Clock,
    tx: &justswap::v1::Transaction,
    log: &justswap::v1::Log,
    tx_index: usize,
    log_index: usize,
    swap: &justswap::v1::TrxPurchase,
) {
    // Create the row and populate common fields
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("justswap_trx_purchase", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Set NewExchange event data
    set_new_exchange(get_new_exchange(store, &log.address), row);

    // Swap info - Token -> TRX
    row.set("buyer", tron_base58_from_bytes(&swap.buyer).unwrap());

    // Token is input, TRX is output
    row.set("tokens_sold", &swap.tokens_sold);
    row.set("trx_bought", &swap.trx_bought);
}

fn process_justswap_add_liquidity(
    store: &FoundationalStore,
    // store: &StoreGetProto<NewExchange>,
    tables: &mut Tables,
    clock: &Clock,
    tx: &justswap::v1::Transaction,
    log: &justswap::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &justswap::v1::AddLiquidity,
) {
    // Create the row and populate common fields
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("justswap_add_liquidity", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Set NewExchange event data
    set_new_exchange(get_new_exchange(store, &log.address), row);

    // Event info
    row.set("provider", tron_base58_from_bytes(&event.provider).unwrap());
    row.set("trx_amount", &event.trx_amount);
    row.set("token_amount", &event.token_amount);
}

fn process_justswap_remove_liquidity(
    store: &FoundationalStore,
    // store: &StoreGetProto<NewExchange>,
    tables: &mut Tables,
    clock: &Clock,
    tx: &justswap::v1::Transaction,
    log: &justswap::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &justswap::v1::RemoveLiquidity,
) {
    // Create the row and populate common fields
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("justswap_remove_liquidity", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Set NewExchange event data
    set_new_exchange(get_new_exchange(store, &log.address), row);

    // Event info
    row.set("provider", tron_base58_from_bytes(&event.provider).unwrap());
    row.set("trx_amount", &event.trx_amount);
    row.set("token_amount", &event.token_amount);
}

fn process_justswap_snapshot(
    store: &FoundationalStore,
    // store: &StoreGetProto<NewExchange>,
    tables: &mut Tables,
    clock: &Clock,
    tx: &justswap::v1::Transaction,
    log: &justswap::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &justswap::v1::Snapshot,
) {
    // Create the row and populate common fields
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("justswap_snapshot", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Set NewExchange event data
    set_new_exchange(get_new_exchange(store, &log.address), row);

    // Event info
    row.set("operator", tron_base58_from_bytes(&event.operator).unwrap());
    row.set("trx_balance", &event.trx_balance);
    row.set("token_balance", &event.token_balance);
}

fn process_justswap_new_exchange(
    tables: &mut Tables,
    clock: &Clock,
    tx: &justswap::v1::Transaction,
    log: &justswap::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &justswap::v1::NewExchange,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("justswap_new_exchange", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Event info
    row.set("exchange", tron_base58_from_bytes(&event.exchange).unwrap());
    row.set("token", tron_base58_from_bytes(&event.token).unwrap());
}
