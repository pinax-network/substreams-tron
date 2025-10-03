mod pb {
    include!(concat!(env!("OUT_DIR"), "/tron.sunswap.v1.rs"));
}

use pb as sunswap_pb;
use substreams_abis::tvm::sunswap::v2::pair::events;
use substreams_ethereum::pb::eth::v2::Block;
use substreams_ethereum::Event;

#[substreams::handlers::map]
fn map_events(block: Block) -> Result<sunswap_pb::Events, substreams::errors::Error> {
    let mut events_output = sunswap_pb::Events::default();
    let mut total_swaps = 0;
    let mut total_mints = 0;
    let mut total_burns = 0;
    let mut total_syncs = 0;

    for trx in block.transactions() {
        let gas_price = trx.clone().gas_price.unwrap_or_default().with_decimal(0).to_string();
        let value = trx.clone().value.unwrap_or_default().with_decimal(0);
        let to = if trx.to.is_empty() { None } else { Some(trx.to.to_vec()) };
        let mut transaction = sunswap_pb::Transaction {
            from: trx.from.to_vec(),
            to,
            hash: trx.hash.to_vec(),
            nonce: trx.nonce,
            gas_price: gas_price.to_string(),
            gas_limit: trx.gas_limit,
            gas_used: trx.receipt().receipt.cumulative_gas_used,
            value: value.to_string(),
            logs: vec![],
        };

        for log_view in trx.receipt().logs() {
            let log = log_view.log;

            // Swap event
            if let Some(event) = events::Swap::match_and_decode(log) {
                total_swaps += 1;
                transaction.logs.push(sunswap_pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(sunswap_pb::log::Log::Swap(sunswap_pb::Swap {
                        sender: event.sender.to_vec(),
                        amount0_in: event.amount0_in.to_string(),
                        amount1_in: event.amount1_in.to_string(),
                        amount0_out: event.amount0_out.to_string(),
                        amount1_out: event.amount1_out.to_string(),
                        to: event.to.to_vec(),
                    })),
                });
            }

            // Mint event
            if let Some(event) = events::Mint::match_and_decode(log) {
                total_mints += 1;
                transaction.logs.push(sunswap_pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(sunswap_pb::log::Log::Mint(sunswap_pb::Mint {
                        sender: event.sender.to_vec(),
                        amount0: event.amount0.to_string(),
                        amount1: event.amount1.to_string(),
                    })),
                });
            }

            // Burn event
            if let Some(event) = events::Burn::match_and_decode(log) {
                total_burns += 1;
                transaction.logs.push(sunswap_pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(sunswap_pb::log::Log::Burn(sunswap_pb::Burn {
                        sender: event.sender.to_vec(),
                        amount0: event.amount0.to_string(),
                        amount1: event.amount1.to_string(),
                        to: event.to.to_vec(),
                    })),
                });
            }

            // Sync event
            if let Some(event) = events::Sync::match_and_decode(log) {
                total_syncs += 1;
                transaction.logs.push(sunswap_pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(sunswap_pb::log::Log::Sync(sunswap_pb::Sync {
                        reserve0: event.reserve0.to_string(),
                        reserve1: event.reserve1.to_string(),
                    })),
                });
            }
        }

        if !transaction.logs.is_empty() {
            events_output.transactions.push(transaction);
        }
    }

    substreams::log::info!("Total Transactions: {}", block.transaction_traces.len());
    substreams::log::info!("Total Swap events: {}", total_swaps);
    substreams::log::info!("Total Mint events: {}", total_mints);
    substreams::log::info!("Total Burn events: {}", total_burns);
    substreams::log::info!("Total Sync events: {}", total_syncs);
    Ok(events_output)
}
