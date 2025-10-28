use proto::pb::tron::sunpump::v1 as pb;
use substreams_abis::tvm::sunpump::v1::launchpad::events;
use substreams_ethereum::pb::eth::v2::{Block, Log};
use substreams_ethereum::Event;

/// Helper function to decode TokenCreateV2 events with a less restrictive length check.
/// The generated match_log in substreams-abis uses `< 256` which is too strict and misses
/// valid events with exactly 256 bytes (minimum size with empty strings).
fn decode_token_create_v2(log: &Log) -> Option<events::TokenCreateV2> {
    // TokenCreateV2 topic ID
    const TOPIC_ID: [u8; 32] = [
        125u8, 53u8, 97u8, 187u8, 108u8, 65u8, 167u8, 121u8, 111u8, 11u8, 106u8, 155u8, 70u8, 59u8, 75u8, 229u8, 51u8, 51u8, 232u8, 99u8, 57u8, 0u8, 92u8,
        89u8, 111u8, 212u8, 229u8, 245u8, 60u8, 156u8, 200u8, 245u8,
    ];

    // Check topic count and ID
    if log.topics.len() != 1 {
        return None;
    }

    if log.topics[0].as_ref() != TOPIC_ID {
        return None;
    }

    // Use a more lenient data length check - minimum 192 bytes for the static parameters
    // The actual minimum with empty strings would be 256 bytes, but we'll be more permissive
    if log.data.len() < 192 {
        return None;
    }

    // Attempt to decode using the generated decode function
    match events::TokenCreateV2::decode(log) {
        Ok(event) => Some(event),
        Err(err) => {
            substreams::log::info!("TokenCreateV2 event at index {} matched topic but failed to decode: {}", log.block_index, err);
            None
        }
    }
}

#[substreams::handlers::map]
fn map_events(block: Block) -> Result<pb::Events, substreams::errors::Error> {
    let mut events = pb::Events::default();
    let mut total_launch_pending = 0;
    let mut total_launcher_changed = 0;
    let mut total_min_tx_fee_set = 0;
    let mut total_mint_fee_set = 0;
    let mut total_operator_changed = 0;
    let mut total_owner_changed = 0;
    let mut total_pending_owner_set = 0;
    let mut total_purchase_fee_set = 0;
    let mut total_sale_fee_set = 0;
    let mut total_token_create = 0;
    let mut total_token_launched = 0;
    let mut total_token_purchased = 0;
    let mut total_token_sold = 0;

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

            // let address = tron_base58_from_bytes(&log.address).unwrap();
            // if address != "TEPcBKJB7N6rF9xKQKPVeSrscsRTfsVFVi" {
            //     // Skip SunPump Token contract logs
            //     continue;
            // }

            // substreams::log::info!("trx = {}", Hex::encode(&trx.hash));
            // substreams::log::info!("log.address = {}", address);
            // if log.topics.len() > 0 {
            //     substreams::log::info!("log.topics[0] = {}", Hex::encode(&log.topics[0]));
            // }
            // if log.topics.len() > 1 {
            //     substreams::log::info!("log.topics[1] = {}", Hex::encode(&log.topics[1]));
            // }
            // if log.topics.len() > 2 {
            //     substreams::log::info!("log.topics[2] = {}", Hex::encode(&log.topics[2]));
            // }
            // substreams::log::info!("log.data = {}\n", Hex::encode(&log.data));

            // LaunchPending event
            if let Some(event) = events::LaunchPending::match_and_decode(log) {
                total_launch_pending += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::LaunchPending(pb::LaunchPending { token: event.token.to_vec() })),
                });
            }

            // LauncherChanged event
            if let Some(event) = events::LauncherChanged::match_and_decode(log) {
                total_launcher_changed += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::LauncherChanged(pb::LauncherChanged {
                        old_launcher: event.old_launcher.to_vec(),
                        new_launcher: event.new_launcher.to_vec(),
                    })),
                });
            }

            // MinTxFeeSet event
            if let Some(event) = events::MinTxFeeSet::match_and_decode(log) {
                total_min_tx_fee_set += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::MinTxFeeSet(pb::MinTxFeeSet {
                        old_fee: event.old_fee.to_string(),
                        new_fee: event.new_fee.to_string(),
                    })),
                });
            }

            // MintFeeSet event
            if let Some(event) = events::MintFeeSet::match_and_decode(log) {
                total_mint_fee_set += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::MintFeeSet(pb::MintFeeSet {
                        old_fee: event.old_fee.to_string(),
                        new_fee: event.new_fee.to_string(),
                    })),
                });
            }

            // OperatorChanged event
            if let Some(event) = events::OperatorChanged::match_and_decode(log) {
                total_operator_changed += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::OperatorChanged(pb::OperatorChanged {
                        old_operator: event.old_operator.to_vec(),
                        new_operator: event.new_operator.to_vec(),
                    })),
                });
            }

            // OwnerChanged event
            if let Some(event) = events::OwnerChanged::match_and_decode(log) {
                total_owner_changed += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::OwnerChanged(pb::OwnerChanged {
                        old_owner: event.old_owner.to_vec(),
                        new_owner: event.new_owner.to_vec(),
                    })),
                });
            }

            // PendingOwnerSet event
            if let Some(event) = events::PendingOwnerSet::match_and_decode(log) {
                total_pending_owner_set += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::PendingOwnerSet(pb::PendingOwnerSet {
                        old_pending_owner: event.old_pending_owner.to_vec(),
                        new_pending_owner: event.new_pending_owner.to_vec(),
                    })),
                });
            }

            // PurchaseFeeSet event
            if let Some(event) = events::PurchaseFeeSet::match_and_decode(log) {
                total_purchase_fee_set += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::PurchaseFeeSet(pb::PurchaseFeeSet {
                        old_fee: event.old_fee.to_string(),
                        new_fee: event.new_fee.to_string(),
                    })),
                });
            }

            // SaleFeeSet event
            if let Some(event) = events::SaleFeeSet::match_and_decode(log) {
                total_sale_fee_set += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::SaleFeeSet(pb::SaleFeeSet {
                        old_fee: event.old_fee.to_string(),
                        new_fee: event.new_fee.to_string(),
                    })),
                });
            }

            // TokenCreate event
            if let Some(event) = events::TokenCreate::match_and_decode(log) {
                total_token_create += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::TokenCreate(pb::TokenCreate {
                        token_address: event.token_address.to_vec(),
                        token_index: event.token_index.to_string(),
                        creator: event.creator.to_vec(),
                        initial_supply: None,
                        name: None,
                        symbol: None,
                    })),
                });
            }

            // TokenCreate event V1
            if let Some(event) = events::TokenCreateV1::match_and_decode(log) {
                total_token_create += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::TokenCreate(pb::TokenCreate {
                        token_address: event.token_address.to_vec(),
                        token_index: event.token_index.to_string(),
                        creator: event.creator.to_vec(),
                        initial_supply: None,
                        name: None,
                        symbol: None,
                    })),
                });
            }

            // TokenCreate event V2
            // Using custom decode function to work around restrictive length check in generated code
            if let Some(event) = decode_token_create_v2(log) {
                total_token_create += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::TokenCreate(pb::TokenCreate {
                        token_address: event.token_address.to_vec(),
                        token_index: event.token_index.to_string(),
                        creator: event.creator.to_vec(),
                        initial_supply: Some(event.initial_supply.to_string()),
                        name: Some(event.name),
                        symbol: Some(event.symbol),
                    })),
                });
            }

            // TokenLaunched event
            if let Some(event) = events::TokenLaunched::match_and_decode(log) {
                total_token_launched += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::TokenLaunched(pb::TokenLaunched { token: event.token.to_vec() })),
                });
            }

            // TokenPurchased event
            if let Some(event) = events::TokenPurchased::match_and_decode(log) {
                total_token_purchased += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::TokenPurchased(pb::TokenPurchased {
                        token: event.token.to_vec(),
                        buyer: event.buyer.to_vec(),
                        trx_amount: event.trx_amount.to_string(),
                        fee: event.fee.to_string(),
                        token_amount: event.token_amount.to_string(),
                        token_reserve: event.token_reserve.to_string(),
                    })),
                });
            }

            // TokenSold event
            if let Some(event) = events::TokenSold::match_and_decode(log) {
                total_token_sold += 1;
                transaction.logs.push(pb::Log {
                    address: log.address.to_vec(),
                    ordinal: log.ordinal,
                    log: Some(pb::log::Log::TokenSold(pb::TokenSold {
                        token: event.token.to_vec(),
                        seller: event.seller.to_vec(),
                        trx_amount: event.trx_amount.to_string(),
                        fee: event.fee.to_string(),
                        token_amount: event.token_amount.to_string(),
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
    substreams::log::info!("Total LaunchPending events: {}", total_launch_pending);
    substreams::log::info!("Total LauncherChanged events: {}", total_launcher_changed);
    substreams::log::info!("Total MinTxFeeSet events: {}", total_min_tx_fee_set);
    substreams::log::info!("Total MintFeeSet events: {}", total_mint_fee_set);
    substreams::log::info!("Total OperatorChanged events: {}", total_operator_changed);
    substreams::log::info!("Total OwnerChanged events: {}", total_owner_changed);
    substreams::log::info!("Total PendingOwnerSet events: {}", total_pending_owner_set);
    substreams::log::info!("Total PurchaseFeeSet events: {}", total_purchase_fee_set);
    substreams::log::info!("Total SaleFeeSet events: {}", total_sale_fee_set);
    substreams::log::info!("Total TokenCreate events: {}", total_token_create);
    substreams::log::info!("Total TokenLaunched events: {}", total_token_launched);
    substreams::log::info!("Total TokenPurchased events: {}", total_token_purchased);
    substreams::log::info!("Total TokenSold events: {}", total_token_sold);
    Ok(events)
}
