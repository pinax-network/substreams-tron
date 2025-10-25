use prost::Message;
use prost_types::Any;
use proto::pb::tron as pb;
use proto::pb::tron::foundational_store::v1::{NewExchange, PairCreated, TokenCreate};
use substreams::pb::sf::substreams::foundational_store::v1::{Entries, Entry};
use substreams::store::StoreSetProto;
use substreams::{prelude::*, Hex};

const URL_PAIR_CREATED: &str = "type.googleapis.com/tron.foundational_store.v1.PairCreated";
const URL_NEW_EXCHANGE: &str = "type.googleapis.com/tron.foundational_store.v1.NewExchange";
const URL_TOKEN_CREATE: &str = "type.googleapis.com/tron.foundational_store.v1.TokenCreate";

#[substreams::handlers::map]
pub fn foundational_store(
    sunswap: pb::sunswap::v1::Events,
    justswap: pb::justswap::v1::Events,
    sunpump: pb::sunpump::v1::Events,
) -> Result<Entries, substreams::errors::Error> {
    let mut entries = Vec::new();

    for trx in sunswap.transactions.iter() {
        for log in trx.logs.iter() {
            // ---- PairCreated ----
            if let Some(pb::sunswap::v1::log::Log::PairCreated(pair_created)) = &log.log {
                let key = pair_created.pair.clone();
                substreams::log::info!("Processing PairCreated for pair: {}", Hex::encode(&key));
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
                substreams::log::info!("Processing NewExchange for exchange: {}", Hex::encode(&key));
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

    for trx in sunpump.transactions.iter() {
        for log in trx.logs.iter() {
            // ---- TokenCreate ----
            if let Some(pb::sunpump::v1::log::Log::TokenCreate(token_create)) = &log.log {
                let key = token_create.token_address.to_vec();
                substreams::log::info!("Processing TokenCreate for token: {}", Hex::encode(&key));
                let payload = TokenCreate {
                    token_address: key.clone(),
                    factory: log.address.clone(),
                    token_index: token_create.token_index.clone(),
                    creator: token_create.creator.clone(),
                };
                entries.push(Entry {
                    key,
                    value: Some(pack_any(&payload, URL_TOKEN_CREATE)),
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
                    pair: pair_created.pair.clone(),
                    factory: log.address.clone(),
                    token0: pair_created.token0.clone(),
                    token1: pair_created.token1.clone(),
                };
                store.set(log.ordinal, Hex::encode(&pair_created.pair), &payload);
            }
        }
    }
}

#[substreams::handlers::store]
pub fn store_new_exchange(justswap: pb::justswap::v1::Events, store: StoreSetProto<NewExchange>) {
    for trx in justswap.transactions.iter() {
        for log in trx.logs.iter() {
            // ---- NewExchange ----
            if let Some(pb::justswap::v1::log::Log::NewExchange(new_exchange)) = &log.log {
                let payload = NewExchange {
                    exchange: new_exchange.exchange.clone(),
                    factory: log.address.clone(),
                    token: new_exchange.token.clone(),
                };
                store.set(log.ordinal, Hex::encode(&new_exchange.exchange), &payload);
            }
        }
    }
}

#[substreams::handlers::store]
pub fn store_token_create(sunpump: pb::sunpump::v1::Events, store: StoreSetProto<TokenCreate>) {
    for trx in sunpump.transactions.iter() {
        for log in trx.logs.iter() {
            // ---- TokenCreate ----
            if let Some(pb::sunpump::v1::log::Log::TokenCreate(token_create)) = &log.log {
                let payload = TokenCreate {
                    token_address: token_create.token_address.clone(),
                    factory: log.address.clone(),
                    token_index: token_create.token_index.clone(),
                    creator: token_create.creator.clone(),
                };
                store.set(log.ordinal, Hex::encode(&token_create.token_address), &payload);
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
