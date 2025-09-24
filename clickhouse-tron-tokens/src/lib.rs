mod logs;
mod transactions;

use proto::pb::tron::transfers::v1 as pb;
use substreams::{errors::Error, pb::substreams::Clock};
use substreams_database_change::pb::database::DatabaseChanges;

#[substreams::handlers::map]
pub fn db_out(clock: Clock, events: pb::Events) -> Result<DatabaseChanges, Error> {
    let mut tables = substreams_database_change::tables::Tables::new();

    // Process logs (TRC20 transfers)
    logs::process_events(&mut tables, &clock, &events);

    // Process transactions (native transfers)
    transactions::process_events(&mut tables, &clock, &events);

    // ONLY include blocks if events are present
    if !tables.tables.is_empty() {
        set_clock(&clock, tables.create_row("cursor", [("cursor", clock.number.to_string())]));
    }

    substreams::log::info!("Total rows {}", tables.all_row_count());
    Ok(tables.to_database_changes())
}

fn set_clock(clock: &Clock, row: &mut substreams_database_change::tables::Row) {
    row.set("block_num", clock.number);
    row.set("block_hash", &clock.id);
    if let Some(timestamp) = &clock.timestamp {
        row.set("timestamp", timestamp.seconds);
    }
}
