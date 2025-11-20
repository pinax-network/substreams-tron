use proto::pb::tron::curvefi::v1 as pb;
use substreams::Hex;
use substreams_ethereum::pb::eth::v2::{Block, Log};

pub mod store;

// Event topic0 hashes from CurveFi Pool.json ABI
const TOKEN_EXCHANGE_TOPIC: &str = "8b3e96f2b889fa771c53c981b40daf005f63f637f1869f707052d15a3dd97140";
const ADD_LIQUIDITY_TOPIC: &str = "26f55a85081d24974e85c6c00045d0f0453991e95873f52bff0d21af4079a768";
const REMOVE_LIQUIDITY_TOPIC: &str = "7c363854ccf79623411f8995b362bce5eddff18c927edc6f5dbbb5e05819a82c";
const REMOVE_LIQUIDITY_ONE_TOPIC: &str = "9e96dd3b997a2a257eec4df9bb6eaf626e206df5f543bd963682d143300be310";
const REMOVE_LIQUIDITY_IMBALANCE_TOPIC: &str = "2b5508378d7e19e0d5fa338419034731416c4f5b219a10379956f764317fd47e";
const COMMIT_NEW_ADMIN_TOPIC: &str = "181aa3aa17d4cbf99265dd4443eba009433d3cde79d60164fde1d1a192beb935";
const NEW_ADMIN_TOPIC: &str = "3b81caf78fa51ecbc8acb482fd7012a277b428d9b80f9d156e8a54107496cc40";
const COMMIT_NEW_FEE_TOPIC: &str = "351fc5da2fbf480f2225debf3664a4bc90fa9923743aad58b4603f648e931fe0";
const NEW_FEE_TOPIC: &str = "be12859b636aed607d5230b2cc2711f68d70e51060e6cca1f575ef5d2fcc95d1";
const RAMP_A_TOPIC: &str = "a2b71ec6df949300b59aab36b55e189697b750119dd349fcfa8c0f779e83c254";
const STOP_RAMP_A_TOPIC: &str = "46e22fb3709ad289f62ce63d469248536dbc78d82b84a3d7e74ad606dc201938";

fn match_topic(log: &Log, topic_hex: &str) -> bool {
    !log.topics.is_empty() && Hex::encode(&log.topics[0]) == topic_hex
}

fn create_log(log: &Log, event: pb::log::Log) -> pb::Log {
    pb::Log {
        address: log.address.to_vec(),
        ordinal: log.ordinal,
        topics: log.topics.iter().map(|t| t.to_vec()).collect(),
        data: log.data.to_vec(),
        log: Some(event),
    }
}

#[substreams::handlers::map]
fn map_events(block: Block) -> Result<pb::Events, substreams::errors::Error> {
    let mut events = pb::Events::default();
    let mut total_token_exchange = 0;
    let mut total_add_liquidity = 0;
    let mut total_remove_liquidity = 0;
    let mut total_remove_liquidity_one = 0;
    let mut total_remove_liquidity_imbalance = 0;
    let mut total_commit_new_admin = 0;
    let mut total_new_admin = 0;
    let mut total_commit_new_fee = 0;
    let mut total_new_fee = 0;
    let mut total_ramp_a = 0;
    let mut total_stop_ramp_a = 0;

    for trx in block.transactions() {
        let gas_price = trx.clone().gas_price.unwrap_or_default().with_decimal(0).to_string();
        let value = trx.clone().value.unwrap_or_default().with_decimal(0);
        let to = if trx.to.is_empty() { None } else { Some(trx.to.to_vec()) };
        let mut transaction = pb::Transaction {
            from: trx.from.to_vec(),
            to,
            hash: trx.hash.to_vec(),
            nonce: trx.nonce,
            gas_price,
            gas_limit: trx.gas_limit,
            gas_used: trx.receipt().receipt.cumulative_gas_used,
            value: value.to_string(),
            logs: vec![],
        };

        for log_view in trx.receipt().logs() {
            let log = log_view.log;

            // TokenExchange event
            if match_topic(log, TOKEN_EXCHANGE_TOPIC) {
                total_token_exchange += 1;
                // Decode event data (simplified - would need full ethabi decoding for production)
                let event = pb::log::Log::TokenExchange(pb::TokenExchange {
                    buyer: vec![], // Would extract from topics[1]
                    sold_id: "0".to_string(),
                    tokens_sold: "0".to_string(),
                    bought_id: "0".to_string(),
                    tokens_bought: "0".to_string(),
                });
                transaction.logs.push(create_log(log, event));
            }

            // AddLiquidity event
            if match_topic(log, ADD_LIQUIDITY_TOPIC) {
                total_add_liquidity += 1;
                let event = pb::log::Log::AddLiquidity(pb::AddLiquidity {
                    provider: vec![], // Would extract from topics[1]
                    token_amounts: vec![],
                    fees: vec![],
                    invariant: "0".to_string(),
                    token_supply: "0".to_string(),
                });
                transaction.logs.push(create_log(log, event));
            }

            // RemoveLiquidity event
            if match_topic(log, REMOVE_LIQUIDITY_TOPIC) {
                total_remove_liquidity += 1;
                let event = pb::log::Log::RemoveLiquidity(pb::RemoveLiquidity {
                    provider: vec![], // Would extract from topics[1]
                    token_amounts: vec![],
                    fees: vec![],
                    token_supply: "0".to_string(),
                });
                transaction.logs.push(create_log(log, event));
            }

            // RemoveLiquidityOne event
            if match_topic(log, REMOVE_LIQUIDITY_ONE_TOPIC) {
                total_remove_liquidity_one += 1;
                let event = pb::log::Log::RemoveLiquidityOne(pb::RemoveLiquidityOne {
                    provider: vec![], // Would extract from topics[1]
                    token_amount: "0".to_string(),
                    coin_amount: "0".to_string(),
                });
                transaction.logs.push(create_log(log, event));
            }

            // RemoveLiquidityImbalance event
            if match_topic(log, REMOVE_LIQUIDITY_IMBALANCE_TOPIC) {
                total_remove_liquidity_imbalance += 1;
                let event = pb::log::Log::RemoveLiquidityImbalance(pb::RemoveLiquidityImbalance {
                    provider: vec![], // Would extract from topics[1]
                    token_amounts: vec![],
                    fees: vec![],
                    invariant: "0".to_string(),
                    token_supply: "0".to_string(),
                });
                transaction.logs.push(create_log(log, event));
            }

            // CommitNewAdmin event
            if match_topic(log, COMMIT_NEW_ADMIN_TOPIC) {
                total_commit_new_admin += 1;
                let event = pb::log::Log::CommitNewAdmin(pb::CommitNewAdmin {
                    deadline: "0".to_string(),
                    admin: vec![],
                });
                transaction.logs.push(create_log(log, event));
            }

            // NewAdmin event
            if match_topic(log, NEW_ADMIN_TOPIC) {
                total_new_admin += 1;
                let event = pb::log::Log::NewAdmin(pb::NewAdmin {
                    admin: vec![], // Would extract from topics[1]
                });
                transaction.logs.push(create_log(log, event));
            }

            // CommitNewFee event
            if match_topic(log, COMMIT_NEW_FEE_TOPIC) {
                total_commit_new_fee += 1;
                let event = pb::log::Log::CommitNewFee(pb::CommitNewFee {
                    deadline: "0".to_string(),
                    fee: "0".to_string(),
                    admin_fee: "0".to_string(),
                });
                transaction.logs.push(create_log(log, event));
            }

            // NewFee event
            if match_topic(log, NEW_FEE_TOPIC) {
                total_new_fee += 1;
                let event = pb::log::Log::NewFee(pb::NewFee {
                    fee: "0".to_string(),
                    admin_fee: "0".to_string(),
                });
                transaction.logs.push(create_log(log, event));
            }

            // RampA event
            if match_topic(log, RAMP_A_TOPIC) {
                total_ramp_a += 1;
                let event = pb::log::Log::RampA(pb::RampA {
                    old_a: "0".to_string(),
                    new_a: "0".to_string(),
                    initial_time: "0".to_string(),
                    future_time: "0".to_string(),
                });
                transaction.logs.push(create_log(log, event));
            }

            // StopRampA event
            if match_topic(log, STOP_RAMP_A_TOPIC) {
                total_stop_ramp_a += 1;
                let event = pb::log::Log::StopRampA(pb::StopRampA {
                    a: "0".to_string(),
                    t: "0".to_string(),
                });
                transaction.logs.push(create_log(log, event));
            }
        }

        if !transaction.logs.is_empty() {
            events.transactions.push(transaction);
        }
    }

    substreams::log::info!("Total Transactions: {}", block.transaction_traces.len());
    substreams::log::info!("Total Events: {}", events.transactions.len());
    substreams::log::info!("Total TokenExchange events: {}", total_token_exchange);
    substreams::log::info!("Total AddLiquidity events: {}", total_add_liquidity);
    substreams::log::info!("Total RemoveLiquidity events: {}", total_remove_liquidity);
    substreams::log::info!("Total RemoveLiquidityOne events: {}", total_remove_liquidity_one);
    substreams::log::info!("Total RemoveLiquidityImbalance events: {}", total_remove_liquidity_imbalance);
    substreams::log::info!("Total CommitNewAdmin events: {}", total_commit_new_admin);
    substreams::log::info!("Total NewAdmin events: {}", total_new_admin);
    substreams::log::info!("Total CommitNewFee events: {}", total_commit_new_fee);
    substreams::log::info!("Total NewFee events: {}", total_new_fee);
    substreams::log::info!("Total RampA events: {}", total_ramp_a);
    substreams::log::info!("Total StopRampA events: {}", total_stop_ramp_a);
    Ok(events)
}
