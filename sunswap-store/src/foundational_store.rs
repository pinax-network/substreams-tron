use prost::Message;
use prost_types::Any;
use proto::pb::tron::sunswap::v1::PairCreated;
use substreams::pb::sf::substreams::foundational_store::v1::{Entries, Entry};
use substreams_abis::tvm::sunswap::v2 as sunswap;
use substreams_ethereum::pb::eth::v2::Block;
use substreams_ethereum::Event;

#[substreams::handlers::map]
pub fn foundational_store_pair_created(block: Block) -> Result<Entries, substreams::errors::Error> {
    let mut entries = Vec::new();

    for trx in block.transactions() {
        for log_view in trx.receipt().logs() {
            let log = log_view.log;
            // PairCreated event
            if let Some(event) = sunswap::factory::events::PairCreated::match_and_decode(log) {
                let pair_created = PairCreated {
                    pair: event.pair.to_vec(),
                    token0: event.token0,
                    token1: event.token1,
                    extra_data: event.extra_data.to_string(),
                };
                let mut buf = Vec::new();
                Message::encode(&pair_created, &mut buf).unwrap();
                let any = Any {
                    type_url: "type.googleapis.com/tron.sunswap.v1.PairCreated".to_string(),
                    value: buf,
                };
                let entry = Entry {
                    key: event.pair,
                    value: Some(any),
                };

                entries.push(entry);
            }
        }
    }

    Ok(Entries { entries })
}
