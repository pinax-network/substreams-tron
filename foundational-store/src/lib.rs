use prost::Message;
use prost_types::Any;
use proto::pb::tron as pb;
use proto::pb::tron::foundational_store::v1::{NewExchange, PairCreated};
use substreams::pb::sf::substreams::foundational_store::v1::{Entries, Entry};

const URL_PAIR_CREATED: &str = "type.googleapis.com/tron.foundational_store.v1.PairCreated";
const URL_NEW_EXCHANGE: &str = "type.googleapis.com/tron.foundational_store.v1.NewExchange";

#[substreams::handlers::map]
pub fn foundational_store(sunswap: pb::sunswap::v1::Events, justswap: pb::justswap::v1::Events) -> Result<Entries, substreams::errors::Error> {
    let mut entries = Vec::new();

    for trx in sunswap.transactions.iter() {
        for log in trx.logs.iter() {
            // ---- PairCreated ----
            if let Some(pb::sunswap::v1::log::Log::PairCreated(pair_created)) = &log.log {
                let key = pair_created.pair.clone();
                let payload = PairCreated {
                    pair: key.clone(),
                    factory: log.address.clone(),
                    token0: pair_created.token0.clone(),
                    token1: pair_created.token1.clone(),
                };
                entries.push(Entry {
                    key,
                    value: Some(pack_any(&payload, URL_PAIR_CREATED)),
                });
            }
        }
    }

    for trx in justswap.transactions.iter() {
        for log in trx.logs.iter() {
            // ---- NewExchange ----
            if let Some(pb::justswap::v1::log::Log::NewExchange(new_exchange)) = &log.log {
                let key = new_exchange.exchange.to_vec();
                let payload = NewExchange {
                    exchange: key.clone(),
                    factory: log.address.clone(),
                    token: new_exchange.token.clone(),
                };
                entries.push(Entry {
                    key,
                    value: Some(pack_any(&payload, URL_NEW_EXCHANGE)),
                });
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
