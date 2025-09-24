mod logs;
mod native_transfers;
mod utils;

use proto::pb::tron::transfers::v1 as pb;
use substreams::{errors::Error, pb::substreams::Clock};
use substreams_database_change::pb::database::DatabaseChanges;
use substreams_database_change::tables::Tables;

#[substreams::handlers::map]
pub fn db_out(clock: Clock, events: pb::Events) -> Result<DatabaseChanges, Error> {
    let mut tables = Tables::new();

    let trc20_transfers = logs::process(&mut tables, &clock, &events);
    let native_transfers = native_transfers::process(&mut tables, &clock, &events);

    substreams::log::info!("Total TRC20 transfers: {} | Total native transfers: {}", trc20_transfers, native_transfers);
    substreams::log::info!("Total rows {}", tables.all_row_count());

    Ok(tables.to_database_changes())
}
