mod justswap;
mod logs;
mod sunpump;
mod sunswap;
mod transactions;

use proto::pb::tron as pb;
use substreams::errors::Error;
use substreams::pb::substreams::Clock;
use substreams_database_change::pb::database::DatabaseChanges;

#[substreams::handlers::map]
pub fn db_out(
    clock: Clock,
    justswap: pb::justswap::v1::Events,
    sunswap: pb::sunswap::v1::Events,
    sunpump: pb::sunpump::v1::Events,
) -> Result<DatabaseChanges, Error> {
    let mut tables = substreams_database_change::tables::Tables::new();

    // Process JustSwap events
    justswap::process_events(&mut tables, &clock, &justswap);

    // Process SunSwap events
    sunswap::process_events(&mut tables, &clock, &sunswap);

    // Process SunPump events
    sunpump::process_events(&mut tables, &clock, &sunpump);

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
    }
}
