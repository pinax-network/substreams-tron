use common::tron_base58_from_bytes;
use proto::pb::tron::{foundational_store::v1::TokenCreate, sunpump};
use substreams::{pb::substreams::Clock, store::StoreGetProto};
use substreams_database_change::tables::Tables;

use crate::{
    foundational_stores::get_token_create,
    logs::{log_key, set_template_log},
    set_clock,
    transactions::set_template_tx,
};

// SunPump Processing
pub fn process_events(tables: &mut Tables, clock: &Clock, events: &sunpump::v1::Events, store: &StoreGetProto<TokenCreate>) {
    for (tx_index, tx) in events.transactions.iter().enumerate() {
        for (log_index, log) in tx.logs.iter().enumerate() {
            match &log.log {
                Some(sunpump::v1::log::Log::TokenPurchased(purchase)) => {
                    process_sunpump_token_purchased(store, tables, clock, tx, log, tx_index, log_index, purchase);
                }
                Some(sunpump::v1::log::Log::TokenSold(sold)) => {
                    process_sunpump_token_sold(store, tables, clock, tx, log, tx_index, log_index, sold);
                }
                Some(sunpump::v1::log::Log::LaunchPending(event)) => {
                    process_sunpump_launch_pending(tables, clock, tx, log, tx_index, log_index, event);
                }
                Some(sunpump::v1::log::Log::LauncherChanged(event)) => {
                    process_sunpump_launcher_changed(tables, clock, tx, log, tx_index, log_index, event);
                }
                Some(sunpump::v1::log::Log::MinTxFeeSet(event)) => {
                    process_sunpump_min_tx_fee_set(tables, clock, tx, log, tx_index, log_index, event);
                }
                Some(sunpump::v1::log::Log::MintFeeSet(event)) => {
                    process_sunpump_mint_fee_set(tables, clock, tx, log, tx_index, log_index, event);
                }
                Some(sunpump::v1::log::Log::OperatorChanged(event)) => {
                    process_sunpump_operator_changed(tables, clock, tx, log, tx_index, log_index, event);
                }
                Some(sunpump::v1::log::Log::OwnerChanged(event)) => {
                    process_sunpump_owner_changed(tables, clock, tx, log, tx_index, log_index, event);
                }
                Some(sunpump::v1::log::Log::PendingOwnerSet(event)) => {
                    process_sunpump_pending_owner_set(tables, clock, tx, log, tx_index, log_index, event);
                }
                Some(sunpump::v1::log::Log::PurchaseFeeSet(event)) => {
                    process_sunpump_purchase_fee_set(tables, clock, tx, log, tx_index, log_index, event);
                }
                Some(sunpump::v1::log::Log::SaleFeeSet(event)) => {
                    process_sunpump_sale_fee_set(tables, clock, tx, log, tx_index, log_index, event);
                }
                Some(sunpump::v1::log::Log::TokenCreate(event)) => {
                    process_sunpump_token_create(tables, clock, tx, log, tx_index, log_index, event);
                }
                Some(sunpump::v1::log::Log::TokenCreateLegacy(event)) => {
                    process_sunpump_token_create_legacy(tables, clock, tx, log, tx_index, log_index, event);
                }
                Some(sunpump::v1::log::Log::TokenLaunched(event)) => {
                    process_sunpump_token_launched(tables, clock, tx, log, tx_index, log_index, event);
                }
                _ => {} // Ignore other event types
            }
        }
    }
}

pub fn set_token_create(value: Option<TokenCreate>, row: &mut substreams_database_change::tables::Row) {
    if let Some(value) = value {
        row.set("factory", tron_base58_from_bytes(&value.factory).unwrap());
        row.set("creator", tron_base58_from_bytes(&value.creator).unwrap());
        row.set("token_index", &value.token_index);
        substreams::log::info!(
            "TokenCreate found: factory={}, creator={}, token_index={}",
            tron_base58_from_bytes(&value.factory).unwrap(),
            tron_base58_from_bytes(&value.creator).unwrap(),
            &value.token_index,
        );
    } else {
        row.set("factory", "");
        row.set("creator", "");
        row.set("token_index", 0);
        substreams::log::info!("TokenCreate not found");
    }
}

fn process_sunpump_token_purchased(
    store: &StoreGetProto<TokenCreate>,
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunpump::v1::Transaction,
    log: &sunpump::v1::Log,
    tx_index: usize,
    log_index: usize,
    purchase: &sunpump::v1::TokenPurchased,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunpump_token_purchased", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Set TokenCreate event data
    set_token_create(get_token_create(store, &purchase.token), row);

    // Swap info - TRX -> Token purchase
    row.set("buyer", tron_base58_from_bytes(&purchase.buyer).unwrap());
    row.set("trx_amount", &purchase.trx_amount);
    row.set("token", tron_base58_from_bytes(&purchase.token).unwrap());
    row.set("token_amount", &purchase.token_amount);
    row.set("fee", &purchase.fee);
    row.set("token_reserve", &purchase.token_reserve);
}

fn process_sunpump_token_sold(
    store: &StoreGetProto<TokenCreate>,
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunpump::v1::Transaction,
    log: &sunpump::v1::Log,
    tx_index: usize,
    log_index: usize,
    sold: &sunpump::v1::TokenSold,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunpump_token_sold", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Set TokenCreate event data
    set_token_create(get_token_create(store, &sold.token), row);

    // Swap info - Token -> TRX sale
    row.set("seller", tron_base58_from_bytes(&sold.seller).unwrap());
    row.set("token", tron_base58_from_bytes(&sold.token).unwrap());
    row.set("token_amount", &sold.token_amount);
    row.set("trx_amount", &sold.trx_amount);
    row.set("fee", &sold.fee);
}

fn process_sunpump_launch_pending(
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunpump::v1::Transaction,
    log: &sunpump::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunpump::v1::LaunchPending,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunpump_launch_pending", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Event info
    row.set("token", tron_base58_from_bytes(&event.token).unwrap());
}

fn process_sunpump_launcher_changed(
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunpump::v1::Transaction,
    log: &sunpump::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunpump::v1::LauncherChanged,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunpump_launcher_changed", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Event info
    row.set("old_launcher", tron_base58_from_bytes(&event.old_launcher).unwrap());
    row.set("new_launcher", tron_base58_from_bytes(&event.new_launcher).unwrap());
}

fn process_sunpump_min_tx_fee_set(
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunpump::v1::Transaction,
    log: &sunpump::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunpump::v1::MinTxFeeSet,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunpump_min_tx_fee_set", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Event info
    row.set("old_fee", &event.old_fee);
    row.set("new_fee", &event.new_fee);
}

fn process_sunpump_mint_fee_set(
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunpump::v1::Transaction,
    log: &sunpump::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunpump::v1::MintFeeSet,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunpump_mint_fee_set", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Event info
    row.set("old_fee", &event.old_fee);
    row.set("new_fee", &event.new_fee);
}

fn process_sunpump_operator_changed(
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunpump::v1::Transaction,
    log: &sunpump::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunpump::v1::OperatorChanged,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunpump_operator_changed", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Event info
    row.set("old_operator", tron_base58_from_bytes(&event.old_operator).unwrap());
    row.set("new_operator", tron_base58_from_bytes(&event.new_operator).unwrap());
}

fn process_sunpump_owner_changed(
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunpump::v1::Transaction,
    log: &sunpump::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunpump::v1::OwnerChanged,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunpump_owner_changed", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Event info
    row.set("old_owner", tron_base58_from_bytes(&event.old_owner).unwrap());
    row.set("new_owner", tron_base58_from_bytes(&event.new_owner).unwrap());
}

fn process_sunpump_pending_owner_set(
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunpump::v1::Transaction,
    log: &sunpump::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunpump::v1::PendingOwnerSet,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunpump_pending_owner_set", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Event info
    row.set("old_pending_owner", tron_base58_from_bytes(&event.old_pending_owner).unwrap());
    row.set("new_pending_owner", tron_base58_from_bytes(&event.new_pending_owner).unwrap());
}

fn process_sunpump_purchase_fee_set(
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunpump::v1::Transaction,
    log: &sunpump::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunpump::v1::PurchaseFeeSet,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunpump_purchase_fee_set", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Event info
    row.set("old_fee", &event.old_fee);
    row.set("new_fee", &event.new_fee);
}

fn process_sunpump_sale_fee_set(
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunpump::v1::Transaction,
    log: &sunpump::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunpump::v1::SaleFeeSet,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunpump_sale_fee_set", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Event info
    row.set("old_fee", &event.old_fee);
    row.set("new_fee", &event.new_fee);
}

fn process_sunpump_token_create(
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunpump::v1::Transaction,
    log: &sunpump::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunpump::v1::TokenCreate,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunpump_token_create", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Event info
    row.set("token_address", tron_base58_from_bytes(&event.token_address).unwrap());
    row.set("token_index", &event.token_index);
    row.set("creator", tron_base58_from_bytes(&event.creator).unwrap());
}

fn process_sunpump_token_create_legacy(
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunpump::v1::Transaction,
    log: &sunpump::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunpump::v1::TokenCreateLegacy,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunpump_token_create_legacy", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Event info
    row.set("token_address", tron_base58_from_bytes(&event.token_address).unwrap());
    row.set("creator", tron_base58_from_bytes(&event.creator).unwrap());
    row.set("nft_max_supply", event.nft_max_supply);
    row.set("nft_threshold", event.nft_threshold);
    row.set("name", &event.name);
    row.set("symbol", &event.symbol);
}

fn process_sunpump_token_launched(
    tables: &mut Tables,
    clock: &Clock,
    tx: &sunpump::v1::Transaction,
    log: &sunpump::v1::Log,
    tx_index: usize,
    log_index: usize,
    event: &sunpump::v1::TokenLaunched,
) {
    let key = log_key(clock, tx_index, log_index);
    let row = tables.create_row("sunpump_token_launched", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Event info
    row.set("token", tron_base58_from_bytes(&event.token).unwrap());
}
