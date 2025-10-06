use common::tron_base58_from_bytes;
use proto::pb::tron::justswap;
use substreams::pb::substreams::Clock;
use substreams_database_change::tables::Tables;

use crate::{
    logs::{log_key, set_template_log},
    set_clock,
    transactions::set_template_tx,
};

// JustSwap Processing
pub fn process_events(tables: &mut Tables, clock: &Clock, events: &justswap::v1::Events) {
    for (tx_index, tx) in events.transactions.iter().enumerate() {
        for (log_index, log) in tx.logs.iter().enumerate() {
            match &log.log {
                Some(justswap::v1::log::Log::TokenPurchase(swap)) => {
                    process_justswap_token_purchase(tables, clock, tx, log, tx_index, log_index, swap);
                }
                Some(justswap::v1::log::Log::TrxPurchase(swap)) => {
                    process_justswap_trx_purchase(tables, clock, tx, log, tx_index, log_index, swap);
                }
                _ => {} // Ignore other event types
            }
        }
    }
}

fn process_justswap_token_purchase(
    tables: &mut Tables,
    clock: &Clock,
    tx: &justswap::v1::Transaction,
    log: &justswap::v1::Log,
    tx_index: usize,
    log_index: usize,
    swap: &justswap::v1::TokenPurchase,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("justswap_token_purchase", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Swap info - TRX -> Token
    row.set("buyer", tron_base58_from_bytes(&swap.buyer).unwrap());
    row.set("trx_sold", &swap.trx_sold);
    row.set("tokens_bought", &swap.tokens_bought);
}

fn process_justswap_trx_purchase(
    tables: &mut Tables,
    clock: &Clock,
    tx: &justswap::v1::Transaction,
    log: &justswap::v1::Log,
    tx_index: usize,
    log_index: usize,
    swap: &justswap::v1::TrxPurchase,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("justswap_trx_purchase", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Swap info - Token -> TRX
    row.set("buyer", tron_base58_from_bytes(&swap.buyer).unwrap());

    // Token is input, TRX is output
    row.set("tokens_sold", &swap.tokens_sold);
    row.set("trx_bought", &swap.trx_bought);
}
