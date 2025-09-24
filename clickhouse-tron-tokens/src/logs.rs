use common::clickhouse::set_clock;
use proto::pb::tron::transfers::v1 as pb;
use substreams::pb::substreams::Clock;
use substreams_database_change::tables::Tables;

use crate::utils::to_hex;

pub fn process(tables: &mut Tables, clock: &Clock, events: &pb::Events) -> usize {
    let mut total = 0;

    for (transaction_index, transaction) in events.transactions.iter().enumerate() {
        for log in &transaction.logs {
            let Some(pb::log::Log::Transfer(transfer)) = &log.log else {
                continue;
            };

            let key = [
                ("block_num", clock.number.to_string()),
                ("transaction_index", transaction_index.to_string()),
                ("log_ordinal", log.ordinal.to_string()),
            ];

            let row = tables.create_row("trc20_transfers", key);
            row.set("transaction_hash", to_hex(&transaction.hash))
                .set("transaction_index", transaction_index as u64)
                .set("log_ordinal", log.ordinal)
                .set("contract_address", to_hex(&log.address))
                .set("from_address", to_hex(&transfer.from))
                .set("to_address", to_hex(&transfer.to))
                .set("amount", &transfer.amount);

            set_clock(clock, row);
            total += 1;
        }
    }

    total
}
