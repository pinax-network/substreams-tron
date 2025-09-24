use substreams::hex;

pub mod clickhouse;

pub type Address = Vec<u8>;
pub type Hash = Vec<u8>;
pub const NULL_ADDRESS: [u8; 20] = hex!("0000000000000000000000000000000000000000");
pub const NULL_HASH: [u8; 32] = hex!("0000000000000000000000000000000000000000000000000000000000000000");
