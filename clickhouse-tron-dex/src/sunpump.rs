use common::tron_base58_from_bytes;
use proto::pb::tron::sunpump;
use substreams::pb::substreams::Clock;
use substreams_database_change::tables::Tables;

use crate::{
    logs::{log_key, set_template_log},
    set_clock,
    transactions::set_template_tx,
};

// SunPump Processing
pub fn process_events(tables: &mut Tables, clock: &Clock, events: &sunpump::v1::Events) {
    for (tx_index, tx) in events.transactions.iter().enumerate() {
        for (log_index, log) in tx.logs.iter().enumerate() {
            match &log.log {
                Some(sunpump::v1::log::Log::TokenPurchased(purchase)) => {
                    process_sunpump_token_purchased(tables, clock, tx, log, tx_index, log_index, purchase);
                }
                Some(sunpump::v1::log::Log::TokenSold(sold)) => {
                    process_sunpump_token_sold(tables, clock, tx, log, tx_index, log_index, sold);
                }
                _ => {} // Ignore other event types
            }
        }
    }
}

fn process_sunpump_token_purchased(
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunpump::v1::Transaction,
    log: &sunpump::v1::Log,
    tx_index: usize,
    log_index: usize,
    purchase: &sunpump::v1::TokenPurchased,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunpump_swaps", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Swap info - TRX -> Token purchase
    row.set("user", tron_base58_from_bytes(&purchase.buyer).unwrap());
    row.set("token", tron_base58_from_bytes(&purchase.token).unwrap());
    row.set("pool", tron_base58_from_bytes(&log.address).unwrap());

    // TRX is input, Token is output
    row.set("input_contract", "TRX");
    row.set("input_amount", &purchase.trx_amount);
    row.set("output_contract", tron_base58_from_bytes(&purchase.token).unwrap());
    row.set("output_amount", &purchase.token_amount);
    row.set("fee", &purchase.fee);
    row.set("token_reserve", &purchase.token_reserve);
}

fn process_sunpump_token_sold(
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunpump::v1::Transaction,
    log: &sunpump::v1::Log,
    tx_index: usize,
    log_index: usize,
    sold: &sunpump::v1::TokenSold,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunpump_swaps", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Swap info - Token -> TRX sale
    row.set("user", tron_base58_from_bytes(&sold.seller).unwrap());
    row.set("token", tron_base58_from_bytes(&sold.token).unwrap());
    row.set("pool", tron_base58_from_bytes(&log.address).unwrap());

    // Token is input, TRX is output
    row.set("input_contract", tron_base58_from_bytes(&sold.token).unwrap());
    row.set("input_amount", &sold.token_amount);
    row.set("output_contract", "TRX");
    row.set("output_amount", &sold.trx_amount);
    row.set("fee", &sold.fee);
}
