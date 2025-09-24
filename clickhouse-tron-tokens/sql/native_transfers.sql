CREATE TABLE IF NOT EXISTS native_transfers
(
    `block_num` UInt64,
    `block_hash` String,
    `timestamp` Int64,
    `transaction_hash` String,
    `transaction_index` UInt32,
    `from_address` String,
    `to_address` String,
    `value` String,
    `gas_price` String,
    `gas_limit` UInt64,
    `gas_used` UInt64,
    `nonce` UInt64
)
ENGINE = MergeTree
PARTITION BY toYear(toDateTime(timestamp))
ORDER BY (block_num, transaction_index);
