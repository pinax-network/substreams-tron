use common::clickhouse::set_clock;
use proto::pb::tron::transfers::v1 as pb;
use substreams::pb::substreams::Clock;
use substreams_database_change::tables::Tables;

use crate::utils::{is_zero_amount, to_hex};

pub fn process(tables: &mut Tables, clock: &Clock, events: &pb::Events) -> usize {
    let mut total = 0;

    for (transaction_index, transaction) in events.transactions.iter().enumerate() {
        if is_zero_amount(&transaction.value) {
            continue;
        }

        let key = [
            ("block_num", clock.number.to_string()),
            ("transaction_index", transaction_index.to_string()),
            ("transfer_type", "native".to_string()),
        ];

        let row = tables.create_row("native_transfers", key);
        row.set("transaction_hash", to_hex(&transaction.hash))
            .set("transaction_index", transaction_index as u64)
            .set("from_address", to_hex(&transaction.from))
            .set("to_address", to_hex(&transaction.to))
            .set("value", &transaction.value)
            .set("gas_price", &transaction.gas_price)
            .set("gas_limit", transaction.gas_limit)
            .set("gas_used", transaction.gas_used)
            .set("nonce", transaction.nonce);

        set_clock(clock, row);
        total += 1;
    }

    total
}
