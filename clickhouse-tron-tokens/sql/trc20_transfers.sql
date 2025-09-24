CREATE TABLE IF NOT EXISTS trc20_transfers
(
    `block_num` UInt64,
    `block_hash` String,
    `timestamp` Int64,
    `transaction_hash` String,
    `transaction_index` UInt32,
    `log_ordinal` UInt64,
    `contract_address` String,
    `from_address` String,
    `to_address` String,
    `amount` String
)
ENGINE = MergeTree
PARTITION BY toYear(toDateTime(timestamp))
ORDER BY (block_num, transaction_index, log_ordinal);
