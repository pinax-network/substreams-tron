use prost::Message;
use prost_types::Any;
use proto::pb::tron as pb;
use proto::pb::tron::foundational_store::v1::PairCreated;
use substreams::pb::sf::substreams::foundational_store::v1::{Entries, Entry};
use substreams::store::StoreSetProto;
use substreams::{prelude::*, Hex};

const URL_PAIR_CREATED: &str = "type.googleapis.com/tron.foundational_store.v1.PairCreated";

#[substreams::handlers::map]
pub fn foundational_store(sunswap: pb::sunswap::v1::Events) -> Result<Entries, substreams::errors::Error> {
    let mut entries = Vec::new();

    for trx in sunswap.transactions.iter() {
        for log in trx.logs.iter() {
            // ---- PairCreated ----
            if let Some(pb::sunswap::v1::log::Log::PairCreated(pair_created)) = &log.log {
                let payload = PairCreated {
                    token0: pair_created.token0.clone(),
                    token1: pair_created.token1.clone(),
                };
                entries.push(Entry {
                    key: log.address.clone(),
                    value: Some(pack_any(&payload, URL_PAIR_CREATED)),
                });
            }
        }
    }

    Ok(Entries { entries })
}

#[substreams::handlers::store]
pub fn store_pair_created(sunswap: pb::sunswap::v1::Events, store: StoreSetProto<PairCreated>) {
    for trx in sunswap.transactions.iter() {
        for log in trx.logs.iter() {
            // ---- PairCreated ----
            if let Some(pb::sunswap::v1::log::Log::PairCreated(pair_created)) = &log.log {
                let payload = PairCreated {
                    token0: pair_created.token0.clone(),
                    token1: pair_created.token1.clone(),
                };
                store.set(log.ordinal, Hex::encode(&log.address), &payload);
            }
        }
    }
}

fn pack_any<T: Message>(msg: &T, type_url: &str) -> Any {
    let mut buf = Vec::with_capacity(msg.encoded_len());
    Message::encode(msg, &mut buf).unwrap();
    Any {
        type_url: type_url.to_string(),
        value: buf,
    }
}
