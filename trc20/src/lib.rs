use common::logs_with_caller;
use proto::pb::tron::trc20::v1 as pb;
use substreams_abis::evm::token::erc20::events;
use substreams_ethereum::pb::eth::v2::Block;
use substreams_ethereum::{Event};

#[substreams::handlers::map]
fn map_events(block: Block) -> Result<pb::Events, substreams::errors::Error> {
    let mut events = pb::Events::default();
    let mut total_transfers = 0;

    for trx in block.transactions() {
        let gas_price = trx.clone().gas_price.unwrap_or_default().with_decimal(0).to_string();
        let value = trx.clone().value.unwrap_or_default().with_decimal(0).to_string();
        for (log, _caller) in logs_with_caller(&block, trx) {
            // Transfer event
            if let Some(event) = events::Transfer::match_and_decode(log) {
                total_transfers += 1;
                events.transactions.push(pb::Transaction {
                    // -- transaction --
                    to: trx.to.to_vec(),
                    hash: trx.hash.to_vec(),
                    nonce: trx.nonce as u64,
                    gas_price: gas_price.to_string(),
                    gas_limit: trx.gas_limit as u64,
                    gas_used: trx.receipt().receipt.cumulative_gas_used,
                    value: value.to_string(),
                    logs: vec![pb::Log {
                        address: log.address.to_vec(),
                        ordinal: log.ordinal,
                        log: Some(pb::log::Log::Transfer(pb::Transfer {
                            from: event.from.to_vec(),
                            to: event.to.to_vec(),
                            amount: event.value.to_string(),
                        })),
                    }],
                });
            }
        }
    }
    substreams::log::info!("Total TRC20 Transfer events: {}", total_transfers);
    Ok(events)
}
