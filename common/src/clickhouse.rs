use substreams::pb::substreams::Clock;
use substreams_database_change::tables::Row;

pub fn set_clock(clock: &Clock, row: &mut Row) {
    let timestamp = clock.timestamp.as_ref().map(|ts| ts.seconds).unwrap_or_default();

    row.set("block_num", clock.number.to_string())
        .set("block_hash", &clock.id)
        .set("timestamp", timestamp);
}
