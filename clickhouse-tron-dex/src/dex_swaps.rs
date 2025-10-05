use common::tron_base58_from_bytes;
use proto::pb::tron::{justswap, sunpump, sunswap};
use substreams::pb::substreams::Clock;
use substreams_database_change::tables::Tables;

use crate::set_clock;

// JustSwap Processing
pub fn process_justswap_events(tables: &mut Tables, clock: &Clock, events: &justswap::v1::Events) {
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
    let row = tables.create_row("justswap_swaps", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Swap info - TRX -> Token
    row.set("user", tron_base58_from_bytes(&swap.buyer).unwrap());
    row.set("pool", tron_base58_from_bytes(&log.address).unwrap());

    // TRX is input, Token is output
    row.set("input_contract", "TRX");
    row.set("input_amount", &swap.trx_sold);
    row.set("output_contract", tron_base58_from_bytes(&log.address).unwrap()); // token contract
    row.set("output_amount", &swap.tokens_bought);
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
    let row = tables.create_row("justswap_swaps", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Swap info - Token -> TRX
    row.set("user", tron_base58_from_bytes(&swap.buyer).unwrap());
    row.set("pool", tron_base58_from_bytes(&log.address).unwrap());

    // Token is input, TRX is output
    row.set("input_contract", tron_base58_from_bytes(&log.address).unwrap()); // token contract
    row.set("input_amount", &swap.tokens_sold);
    row.set("output_contract", "TRX");
    row.set("output_amount", &swap.trx_bought);
}

// SunSwap Processing
pub fn process_sunswap_events(tables: &mut Tables, clock: &Clock, events: &sunswap::v1::Events) {
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
    let row = tables.create_row("sunswap_swaps", key);

    // Block and transaction info
    set_clock(clock, row);
    set_template_tx(tx, tx_index, row);
    set_template_log(log, log_index, row);

    // Swap info
    row.set("sender", tron_base58_from_bytes(&swap.sender).unwrap());
    row.set("to", tron_base58_from_bytes(&swap.to).unwrap());
    row.set("pool", tron_base58_from_bytes(&log.address).unwrap());

    // Determine which direction the swap is going
    // If amount0_in > 0, then token0 is input and token1 is output
    // If amount1_in > 0, then token1 is input and token0 is output
    if swap.amount0_in != "0" && !swap.amount0_in.is_empty() {
        // token0 -> token1
        row.set("input_contract", "token0"); // Will be resolved in materialized view
        row.set("input_amount", &swap.amount0_in);
        row.set("output_contract", "token1");
        row.set("output_amount", &swap.amount1_out);
    } else {
        // token1 -> token0
        row.set("input_contract", "token1");
        row.set("input_amount", &swap.amount1_in);
        row.set("output_contract", "token0");
        row.set("output_amount", &swap.amount0_out);
    }

    // Store all amounts for reference
    row.set("amount0_in", &swap.amount0_in);
    row.set("amount1_in", &swap.amount1_in);
    row.set("amount0_out", &swap.amount0_out);
    row.set("amount1_out", &swap.amount1_out);
}

// SunPump Processing
pub fn process_sunpump_events(tables: &mut Tables, clock: &Clock, events: &sunpump::v1::Events) {
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

// Helper functions
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

fn set_template_log(log: &impl LogAddress, log_index: usize, row: &mut substreams_database_change::tables::Row) {
    row.set("log_index", log_index as u32);
    row.set("log_address", tron_base58_from_bytes(log.get_address()).unwrap());
    row.set("log_ordinal", log.get_ordinal());
}

fn set_template_tx(tx: &impl TxTemplate, tx_index: usize, row: &mut substreams_database_change::tables::Row) {
    let tx_to = match tx.get_to() {
        Some(addr) => tron_base58_from_bytes(addr).unwrap(),
        None => "".to_string(),
    };
    row.set("tx_index", tx_index as u32);
    row.set("tx_hash", hex::encode(tx.get_hash()));
    row.set("tx_from", tron_base58_from_bytes(tx.get_from()).unwrap());
    row.set("tx_to", tx_to);
    row.set("tx_nonce", tx.get_nonce());
    row.set("tx_gas_price", tx.get_gas_price());
    row.set("tx_gas_limit", tx.get_gas_limit());
    row.set("tx_gas_used", tx.get_gas_used());
    row.set("tx_value", tx.get_value());
}

// Trait to abstract over different log types
trait LogAddress {
    fn get_address(&self) -> &Vec<u8>;
    fn get_ordinal(&self) -> u64;
}

impl LogAddress for justswap::v1::Log {
    fn get_address(&self) -> &Vec<u8> {
        &self.address
    }
    fn get_ordinal(&self) -> u64 {
        self.ordinal
    }
}

impl LogAddress for sunswap::v1::Log {
    fn get_address(&self) -> &Vec<u8> {
        &self.address
    }
    fn get_ordinal(&self) -> u64 {
        self.ordinal
    }
}

impl LogAddress for sunpump::v1::Log {
    fn get_address(&self) -> &Vec<u8> {
        &self.address
    }
    fn get_ordinal(&self) -> u64 {
        self.ordinal
    }
}

// Trait to abstract over different transaction types
trait TxTemplate {
    fn get_hash(&self) -> &Vec<u8>;
    fn get_from(&self) -> &Vec<u8>;
    fn get_to(&self) -> &Option<Vec<u8>>;
    fn get_nonce(&self) -> u64;
    fn get_gas_price(&self) -> &str;
    fn get_gas_limit(&self) -> u64;
    fn get_gas_used(&self) -> u64;
    fn get_value(&self) -> &str;
}

impl TxTemplate for justswap::v1::Transaction {
    fn get_hash(&self) -> &Vec<u8> {
        &self.hash
    }
    fn get_from(&self) -> &Vec<u8> {
        &self.from
    }
    fn get_to(&self) -> &Option<Vec<u8>> {
        &self.to
    }
    fn get_nonce(&self) -> u64 {
        self.nonce
    }
    fn get_gas_price(&self) -> &str {
        &self.gas_price
    }
    fn get_gas_limit(&self) -> u64 {
        self.gas_limit
    }
    fn get_gas_used(&self) -> u64 {
        self.gas_used
    }
    fn get_value(&self) -> &str {
        &self.value
    }
}

impl TxTemplate for sunswap::v1::Transaction {
    fn get_hash(&self) -> &Vec<u8> {
        &self.hash
    }
    fn get_from(&self) -> &Vec<u8> {
        &self.from
    }
    fn get_to(&self) -> &Option<Vec<u8>> {
        &self.to
    }
    fn get_nonce(&self) -> u64 {
        self.nonce
    }
    fn get_gas_price(&self) -> &str {
        &self.gas_price
    }
    fn get_gas_limit(&self) -> u64 {
        self.gas_limit
    }
    fn get_gas_used(&self) -> u64 {
        self.gas_used
    }
    fn get_value(&self) -> &str {
        &self.value
    }
}

impl TxTemplate for sunpump::v1::Transaction {
    fn get_hash(&self) -> &Vec<u8> {
        &self.hash
    }
    fn get_from(&self) -> &Vec<u8> {
        &self.from
    }
    fn get_to(&self) -> &Option<Vec<u8>> {
        &self.to
    }
    fn get_nonce(&self) -> u64 {
        self.nonce
    }
    fn get_gas_price(&self) -> &str {
        &self.gas_price
    }
    fn get_gas_limit(&self) -> u64 {
        self.gas_limit
    }
    fn get_gas_used(&self) -> u64 {
        self.gas_used
    }
    fn get_value(&self) -> &str {
        &self.value
    }
}
