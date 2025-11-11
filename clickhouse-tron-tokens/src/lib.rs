mod logs;
mod native_transfers;
mod transactions;
mod weth;
mod trc20_transfers;
use substreams::pb::substreams::Clock;

use proto::pb::tron as pb;
use substreams::errors::Error;
use substreams_database_change::pb::database::DatabaseChanges;

#[substreams::handlers::map]
pub fn db_out(clock: Clock, transfers: pb::transfers::v1::Events) -> Result<DatabaseChanges, Error> {
    let mut tables = substreams_database_change::tables::Tables::new();

    // Process logs (TRC20 transfers)
    trc20_transfers::process_events(&mut tables, &clock, &transfers);

    // Process transactions (Native transfers)
    native_transfers::process_events(&mut tables, &clock, &transfers);

    // Process WETH events
    weth::process_events(&mut tables, &clock, &transfers);

    // ONLY include blocks if events are present
    if !tables.tables.is_empty() {
        set_clock(&clock, tables.create_row("blocks", [("block_num", clock.number.to_string())]));
    }

    substreams::log::info!("Total rows {}", tables.all_row_count());
    Ok(tables.to_database_changes())
}

pub fn set_clock(clock: &Clock, row: &mut substreams_database_change::tables::Row) {
    row.set("block_num", clock.number);
    row.set("block_hash", &clock.id);
    if let Some(timestamp) = &clock.timestamp {
        row.set("timestamp", timestamp.seconds);
        row.set("minute", timestamp.seconds / 60);
    }
}
