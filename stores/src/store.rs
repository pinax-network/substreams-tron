use proto::pb::tron::stores::v1::PairCreatedStore;
use substreams::store::StoreSetProto;
use substreams::{prelude::*, Hex};
use substreams_abis::tvm::sunswap::v2 as sunswap;
use substreams_ethereum::pb::eth::v2::Block;
use substreams_ethereum::Event;

#[substreams::handlers::store]
pub fn store_pair_created(block: Block, store: StoreSetProto<PairCreatedStore>) {
    for trx in block.transactions() {
        for log_view in trx.receipt().logs() {
            let log = log_view.log;
            // PairCreated event
            if let Some(event) = sunswap::factory::events::PairCreated::match_and_decode(log) {
                let pair_created = PairCreatedStore {
                    token0: event.token0,
                    token1: event.token1,
                };
                store.set(0, Hex::encode(event.pair), &pair_created);
            }
        }
    }
}
