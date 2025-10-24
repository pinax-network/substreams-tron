use proto::pb::tron::foundational_store::v1::{NewExchange, PairCreated};
use substreams::{
    store::{FoundationalStore, StoreGet, StoreGetProto},
    Hex,
};

pub fn get_new_exchange(store: &FoundationalStore, address: &Vec<u8>) -> Option<NewExchange> {
    let new_exchange = store.get(address.to_vec());
    if let Some(value) = &new_exchange.value {
        substreams::log::info!("Found value with type_url: {}", value.type_url);
        if value.type_url == "type.googleapis.com/tron.foundational_store.v1.NewExchange" {
            if let Ok(decoded) = prost::Message::decode(value.value.as_slice()) {
                let exchange: NewExchange = decoded;
                return Some(exchange);
            }
        }
    }
    None
}

pub fn get_pair_created(store: &FoundationalStore, address: &Vec<u8>) -> Option<PairCreated> {
    let pair_created = store.get(address.to_vec());
    if let Some(value) = &pair_created.value {
        substreams::log::info!("Found value with type_url: {}", value.type_url);
        if value.type_url == "type.googleapis.com/tron.foundational_store.v1.PairCreated" {
            if let Ok(decoded) = prost::Message::decode(value.value.as_slice()) {
                let pair: PairCreated = decoded;
                return Some(pair);
            }
        }
    }
    None
}

pub fn _get_new_exchange(store: &StoreGetProto<NewExchange>, address: &Vec<u8>) -> Option<NewExchange> {
    store.get_first(Hex::encode(address))
}

pub fn _get_pair_created(store: &StoreGetProto<PairCreated>, address: &Vec<u8>) -> Option<PairCreated> {
    store.get_first(Hex::encode(address))
}
