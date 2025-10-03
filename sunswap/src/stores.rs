use prost_types::Any;
use proto::pb::sf::substreams::foundational_store::v1::{Entries, Entry};
use substreams_abis::tvm::sunswap::v2 as sunswap;
use substreams_ethereum::pb::eth::v2::Block;
use substreams_ethereum::Event;

#[substreams::handlers::map]
pub fn store_pair_created(block: Block) -> Result<Entries, substreams::errors::Error> {
    let mut entries = Vec::new();

    for trx in block.transactions() {
        for log_view in trx.receipt().logs() {
            let log = log_view.log;
            // PairCreated event
            if let Some(event) = sunswap::factory::events::PairCreated::match_and_decode(log) {
                // Wrap in Any type with type URL
                // combine token0 & token1 into Any type with empty type URL
                substreams::log::info!("length of token0: {}", event.token0.len());
                substreams::log::info!("length of token1: {}", event.token1.len());
                let any = Any {
                    type_url: "".to_string(),
                    value: [event.token0.to_vec(), event.token1.to_vec()].concat(),
                };
                // Create entry with pair address as key
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
