use prost::Message;
use prost_types::Any;
use proto::pb::tron::foundational_store::v1::PairCreated;
use substreams::pb::sf::substreams::foundational_store::v1::{Entries, Entry};
use substreams_abis::tvm::sunswap::v2 as sunswap;
use substreams_ethereum::pb::eth::v2::Block;
use substreams_ethereum::Event;

const URL_PAIR_CREATED: &str = "type.googleapis.com/tron.foundational_store.v1.PairCreated";

#[substreams::handlers::map]
pub fn foundational_store(block: Block) -> Result<Entries, substreams::errors::Error> {
    let mut entries = Vec::new();

    for trx in block.transactions() {
        for log_view in trx.receipt().logs() {
            let log = log_view.log;

            // ---- PairCreated ----
            if let Some(event) = sunswap::factory::events::PairCreated::match_and_decode(log.clone()) {
                let payload = PairCreated {
                    token0: event.token0,
                    token1: event.token1,
                };
                entries.push(Entry {
                    key: event.pair,
                    value: Some(pack_any(&payload, URL_PAIR_CREATED)),
                })
            }
        }
    }

    Ok(Entries { entries })
}

fn pack_any<T: Message>(msg: &T, type_url: &str) -> Any {
    let mut buf = Vec::with_capacity(msg.encoded_len());
    Message::encode(msg, &mut buf).unwrap();
    Any {
        type_url: type_url.to_string(),
        value: buf,
    }
}
