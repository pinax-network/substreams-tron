use substreams_tron_proto::{Block, BlockHeader, ResponseCode, Transaction};

/// Basic Tron block representation for internal use
#[derive(Debug, Clone)]
pub struct TronBlock {
    pub id: Vec<u8>,
    pub header: TronBlockHeader,
    pub transactions: Vec<TronTransaction>,
}

/// Basic Tron block header representation
#[derive(Debug, Clone)]
pub struct TronBlockHeader {
    pub number: u64,
    pub tx_trie_root: Vec<u8>,
    pub witness_address: Vec<u8>,
    pub parent_number: u64,
    pub parent_hash: Vec<u8>,
    pub version: u32,
    pub timestamp: i64,
    pub witness_signature: Vec<u8>,
}

/// Basic Tron transaction representation
#[derive(Debug, Clone)]
pub struct TronTransaction {
    pub id: Vec<u8>,
    pub signature: Vec<Vec<u8>>,
    pub ref_block_bytes: Vec<u8>,
    pub ref_block_hash: Vec<u8>,
    pub expiration: i64,
    pub timestamp: i64,
    pub contract_result: Vec<Vec<u8>>,
    pub result: bool,
    pub code: i32,
    pub ret_message: Vec<u8>,
    pub energy_used: i64,
    pub energy_penalty: i64,
}

/// Converts a Tron block to our proto definition
pub fn convert_block(block: &TronBlock) -> Block {
    Block {
        id: block.id.clone(),
        header: Some(convert_block_header(&block.header)),
        transactions: block.transactions.iter().map(convert_transaction).collect(),
    }
}

/// Converts a Tron block header
pub fn convert_block_header(header: &TronBlockHeader) -> BlockHeader {
    BlockHeader {
        number: header.number,
        tx_trie_root: header.tx_trie_root.clone(),
        witness_address: header.witness_address.clone(),
        parent_number: header.parent_number,
        parent_hash: header.parent_hash.clone(),
        version: header.version,
        timestamp: header.timestamp,
        witness_signature: header.witness_signature.clone(),
    }
}

/// Converts a Tron transaction
pub fn convert_transaction(transaction: &TronTransaction) -> Transaction {
    Transaction {
        txid: transaction.id.clone(),
        signature: transaction.signature.clone(),
        ref_block_bytes: transaction.ref_block_bytes.clone(),
        ref_block_hash: transaction.ref_block_hash.clone(),
        expiration: transaction.expiration,
        timestamp: transaction.timestamp,
        contract_result: transaction.contract_result.clone(),
        result: transaction.result,
        code: transaction.code,
        message: transaction.ret_message.clone(),
        energy_used: transaction.energy_used,
        energy_penalty: transaction.energy_penalty,
        contracts: vec![], // Simplified for now - can be extended
    }
}

/// Helper function to format Tron addresses
pub fn format_address(address: &[u8]) -> String {
    if address.is_empty() {
        return String::new();
    }
    hex::encode(address)
}

/// Helper function to format transaction hash
pub fn format_tx_hash(hash: &[u8]) -> String {
    if hash.is_empty() {
        return String::new();
    }
    hex::encode(hash)
}

/// Creates a sample Tron block for testing/demonstration
pub fn create_sample_block() -> TronBlock {
    TronBlock {
        id: vec![0x01, 0x02, 0x03, 0x04],
        header: TronBlockHeader {
            number: 66000000,
            tx_trie_root: vec![0x05, 0x06, 0x07, 0x08],
            witness_address: vec![0x09, 0x0a, 0x0b, 0x0c],
            parent_number: 65999999,
            parent_hash: vec![0x0d, 0x0e, 0x0f, 0x10],
            version: 1,
            timestamp: 1640995200000, // Example timestamp
            witness_signature: vec![0x11, 0x12, 0x13, 0x14],
        },
        transactions: vec![TronTransaction {
            id: vec![0x15, 0x16, 0x17, 0x18],
            signature: vec![vec![0x19, 0x1a, 0x1b, 0x1c]],
            ref_block_bytes: vec![0x1d, 0x1e],
            ref_block_hash: vec![0x1f, 0x20, 0x21, 0x22],
            expiration: 1640995260000,
            timestamp: 1640995200000,
            contract_result: vec![],
            result: true,
            code: ResponseCode::Success as i32,
            ret_message: vec![],
            energy_used: 21000,
            energy_penalty: 0,
        }],
    }
}
