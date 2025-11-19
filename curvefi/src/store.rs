use proto::pb::tron::curvefi::v1 as pb;
use substreams::store::{StoreNew, StoreSet, StoreSetProto};
use substreams::Hex;

/// Store handler for tracking liquidity providers in CurveFi pools
#[substreams::handlers::store]
pub fn store_pool_info(events: pb::Events, store: StoreSetProto<pb::PoolInfo>) {
    for trx in events.transactions.iter() {
        for log in trx.logs.iter() {
            // Track AddLiquidity events
            if let Some(pb::log::Log::AddLiquidity(add_liquidity)) = &log.log {
                let key = format!("{}:{}", Hex::encode(&log.address), Hex::encode(&add_liquidity.provider));
                let payload = pb::PoolInfo {
                    pool_address: log.address.clone(),
                    provider: add_liquidity.provider.clone(),
                    total_liquidity: add_liquidity.token_supply.clone(),
                };
                store.set(log.ordinal, &key, &payload);
            }

            // Track RemoveLiquidity events
            if let Some(pb::log::Log::RemoveLiquidity(remove_liquidity)) = &log.log {
                let key = format!("{}:{}", Hex::encode(&log.address), Hex::encode(&remove_liquidity.provider));
                let payload = pb::PoolInfo {
                    pool_address: log.address.clone(),
                    provider: remove_liquidity.provider.clone(),
                    total_liquidity: remove_liquidity.token_supply.clone(),
                };
                store.set(log.ordinal, &key, &payload);
            }

            // Track RemoveLiquidityOne events
            if let Some(pb::log::Log::RemoveLiquidityOne(remove_liquidity_one)) = &log.log {
                let key = format!("{}:{}", Hex::encode(&log.address), Hex::encode(&remove_liquidity_one.provider));
                // For RemoveLiquidityOne, we use token_amount as an indicator
                let payload = pb::PoolInfo {
                    pool_address: log.address.clone(),
                    provider: remove_liquidity_one.provider.clone(),
                    total_liquidity: remove_liquidity_one.token_amount.clone(),
                };
                store.set(log.ordinal, &key, &payload);
            }

            // Track RemoveLiquidityImbalance events
            if let Some(pb::log::Log::RemoveLiquidityImbalance(remove_liquidity_imbalance)) = &log.log {
                let key = format!("{}:{}", Hex::encode(&log.address), Hex::encode(&remove_liquidity_imbalance.provider));
                let payload = pb::PoolInfo {
                    pool_address: log.address.clone(),
                    provider: remove_liquidity_imbalance.provider.clone(),
                    total_liquidity: remove_liquidity_imbalance.token_supply.clone(),
                };
                store.set(log.ordinal, &key, &payload);
            }
        }
    }
}
