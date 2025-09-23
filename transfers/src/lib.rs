use common::logs_with_caller;
use proto::pb::tron::trc20::v1 as pb;
use substreams_abis::evm::token::erc20::events;
use substreams_ethereum::pb::eth::v2::Block;
use substreams_ethereum::{Event};

#[substreams::handlers::map]
fn map_events(block: Block) -> Result<pb::Events, substreams::errors::Error> {
    let mut events = pb::Events::default();
    let mut total_trc20_transfers = 0;
    let mut total_native_transfers = 0;

    for trx in block.transactions() {
        let gas_price = trx.clone().gas_price.unwrap_or_default().with_decimal(0).to_string();
        let value = trx.clone().value.unwrap_or_default().with_decimal(0);
        let mut transaction = pb::Transaction {
                // -- transaction --
                to: trx.to.to_vec(),
                hash: trx.hash.to_vec(),
                nonce: trx.nonce as u64,
                gas_price: gas_price.to_string(),
                gas_limit: trx.gas_limit as u64,
                gas_used: trx.receipt().receipt.cumulative_gas_used,
                value: value.to_string(),
                logs: vec![],
        };
        for log_view in trx.receipt().logs() {
            let log = log_view.log;
            // TRC-20 Transfer event
            if let Some(event) = events::Transfer::match_and_decode(log) {
                total_trc20_transfers += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::Transfer(pb::Transfer {
                        from: event.from.to_vec(),
                        to: event.to.to_vec(),
                        amount: event.value.to_string(),
                    })),
                });
            }
        }
        // Native transfer
        if !value.is_zero() {
            total_native_transfers += 1;
        }
        if !value.is_zero() || transaction.logs.len() > 0 {
            // Only include transactions with value or logs
            events.transactions.push(transaction);
        }
    }
    substreams::log::info!("Total Transactions: {}", block.transaction_traces.len());
    substreams::log::info!("Total TRC20 Transfer events: {}", total_trc20_transfers);
    substreams::log::info!("Total Native transfers: {}", total_native_transfers);
    Ok(events)
}
