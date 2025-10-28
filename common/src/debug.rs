use substreams::Hex;
use substreams_ethereum::pb::eth::v2::{Log, TransactionTrace};

use crate::tron_base58_from_bytes;

pub fn _debug_log(trx: &TransactionTrace, log: &Log) {
    let address = tron_base58_from_bytes(&log.address).unwrap();

    substreams::log::info!("trx = {}", Hex::encode(&trx.hash));
    substreams::log::info!("log.address = {}", address);
    if log.topics.len() > 0 {
        substreams::log::info!("log.topics[0] = {}", Hex::encode(&log.topics[0]));
    }
    if log.topics.len() > 1 {
        substreams::log::info!("log.topics[1] = {}", Hex::encode(&log.topics[1]));
    }
    if log.topics.len() > 2 {
        substreams::log::info!("log.topics[2] = {}", Hex::encode(&log.topics[2]));
    }
    substreams::log::info!("log.data = {}\n", Hex::encode(&log.data));
}
