use proto::pb::tron::justswap::v1 as pb;
use substreams_abis::tvm::justswap::v1::exchange::events;
use substreams_ethereum::pb::eth::v2::Block;
use substreams_ethereum::Event;

#[substreams::handlers::map]
fn map_events(block: Block) -> Result<pb::Events, substreams::errors::Error> {
    let mut events = pb::Events::default();
    let mut total_token_purchases = 0;
    let mut total_trx_purchases = 0;
    let mut total_add_liquidity = 0;
    let mut total_remove_liquidity = 0;
    let mut total_snapshot = 0;

    for trx in block.transactions() {
        let gas_price = trx.clone().gas_price.unwrap_or_default().with_decimal(0).to_string();
        let value = trx.clone().value.unwrap_or_default().with_decimal(0);
        let to = if trx.to.is_empty() { None } else { Some(trx.to.to_vec()) };
        let mut transaction = pb::Transaction {
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

            // TokenPurchase event
            if let Some(event) = events::TokenPurchase::match_and_decode(log) {
                total_token_purchases += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::TokenPurchase(pb::TokenPurchase {
                        buyer: event.buyer.to_vec(),
                        trx_sold: event.trx_sold.to_string(),
                        tokens_bought: event.tokens_bought.to_string(),
                    })),
                });
            }

            // TrxPurchase event
            if let Some(event) = events::TrxPurchase::match_and_decode(log) {
                total_trx_purchases += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::TrxPurchase(pb::TrxPurchase {
                        buyer: event.buyer.to_vec(),
                        tokens_sold: event.tokens_sold.to_string(),
                        trx_bought: event.trx_bought.to_string(),
                    })),
                });
            }

            // AddLiquidity event
            if let Some(event) = events::AddLiquidity::match_and_decode(log) {
                total_add_liquidity += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::AddLiquidity(pb::AddLiquidity {
                        provider: event.provider.to_vec(),
                        trx_amount: event.trx_amount.to_string(),
                        token_amount: event.token_amount.to_string(),
                    })),
                });
            }

            // RemoveLiquidity event
            if let Some(event) = events::RemoveLiquidity::match_and_decode(log) {
                total_remove_liquidity += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::RemoveLiquidity(pb::RemoveLiquidity {
                        provider: event.provider.to_vec(),
                        trx_amount: event.trx_amount.to_string(),
                        token_amount: event.token_amount.to_string(),
                    })),
                });
            }

            // Snapshot event
            if let Some(event) = events::Snapshot::match_and_decode(log) {
                total_snapshot += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::Snapshot(pb::Snapshot {
                        operator: event.operator.to_vec(),
                        trx_balance: event.trx_balance.to_string(),
                        token_balance: event.token_balance.to_string(),
                    })),
                });
            }
        }

        if !transaction.logs.is_empty() {
            events.transactions.push(transaction);
        }
    }

    substreams::log::info!("Total Transactions: {}", block.transaction_traces.len());
    substreams::log::info!("Total Events: {}", events.transactions.len());
    substreams::log::info!("Total TokenPurchase events: {}", total_token_purchases);
    substreams::log::info!("Total TrxPurchase events: {}", total_trx_purchases);
    substreams::log::info!("Total AddLiquidity events: {}", total_add_liquidity);
    substreams::log::info!("Total RemoveLiquidity events: {}", total_remove_liquidity);
    substreams::log::info!("Total Snapshot events: {}", total_snapshot);
    Ok(events)
}
