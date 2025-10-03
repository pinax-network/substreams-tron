use prost::Message;
use prost_types::Any;
use proto::pb::sf::substreams::foundational_store::v1::{Entries, Entry};
use proto::pb::tron::sunswap::v1 as pb;

#[substreams::handlers::map]
pub fn store_pair_created(events: pb::Events) -> Result<Entries, substreams::errors::Error> {
    let mut entries = Vec::new();

    for transaction in events.transactions {
        for log in transaction.logs {
            if let Some(pb::log::Log::PairCreated(pair_created)) = log.log {
                // Encode the PairCreated message as protobuf bytes
                let mut buf = Vec::new();
                Message::encode(&pair_created, &mut buf).unwrap();

                // Wrap in Any type with type URL
                let any = Any {
                    type_url: "type.googleapis.com/tron.sunswap.v1.PairCreated".to_string(),
                    value: buf,
                };

                // Create entry with pair address as key
                let entry = Entry {
                    key: pair_created.pair.clone(),
                    value: Some(any),
                };

                entries.push(entry);
            }
        }
    }

    Ok(Entries { entries })
}
