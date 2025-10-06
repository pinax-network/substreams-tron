use common::tron_base58_from_bytes;
use proto::pb::tron::{justswap, sunpump, sunswap};

pub fn set_template_tx(tx: &impl TxTemplate, tx_index: usize, row: &mut substreams_database_change::tables::Row) {
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

// Trait to abstract over different transaction types
pub trait TxTemplate {
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
