use common::tron_base58_from_bytes;
use proto::pb::tron::{justswap, sunpump, sunswap};
use substreams::{pb::substreams::Clock, Hex};

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

pub fn set_template_log(log: &impl LogAddress, log_index: usize, row: &mut substreams_database_change::tables::Row) {
    row.set("log_index", log_index as u32);
    row.set("log_address", tron_base58_from_bytes(log.get_address()).unwrap());
    row.set("log_ordinal", log.get_ordinal());

    // handle if topic0 exists, else set to empty string
    if let Some(topic0) = log.get_topic0() {
        row.set("log_topic0", Hex::encode(topic0));
    } else {
        row.set("log_topic0", "");
    }
}

// Trait to abstract over different log types
pub trait LogAddress {
    fn get_address(&self) -> &Vec<u8>;
    fn get_ordinal(&self) -> u64;
    fn get_topics(&self) -> &Vec<Vec<u8>>;
    fn get_topic0(&self) -> Option<&Vec<u8>> {
        self.get_topics().get(0)
    }
    fn _get_data(&self) -> &Vec<u8>;
}

impl LogAddress for justswap::v1::Log {
    fn get_address(&self) -> &Vec<u8> {
        &self.address
    }
    fn get_ordinal(&self) -> u64 {
        self.ordinal
    }
    fn get_topics(&self) -> &Vec<Vec<u8>> {
        &self.topics
    }
    fn _get_data(&self) -> &Vec<u8> {
        &self.data
    }
}

impl LogAddress for sunswap::v1::Log {
    fn get_address(&self) -> &Vec<u8> {
        &self.address
    }
    fn get_ordinal(&self) -> u64 {
        self.ordinal
    }
    fn get_topics(&self) -> &Vec<Vec<u8>> {
        &self.topics
    }
    fn _get_data(&self) -> &Vec<u8> {
        &self.data
    }
}

impl LogAddress for sunpump::v1::Log {
    fn get_address(&self) -> &Vec<u8> {
        &self.address
    }
    fn get_ordinal(&self) -> u64 {
        self.ordinal
    }
    fn get_topics(&self) -> &Vec<Vec<u8>> {
        &self.topics
    }
    fn _get_data(&self) -> &Vec<u8> {
        &self.data
    }
}
