-- Native transfer by minutes
-- used for optimizing queries that need to filter by minute intervals
-- `index_granularity` values are chosen to balance compression and query performance
CREATE TABLE IF NOT EXISTS native_transfer_from_minutes ON CLUSTER 'tokenapis-a' (
    `from`              LowCardinality(String) COMMENT 'sender address',
    minute              DateTime('UTC') COMMENT 'start minute of the transfers',
)
ENGINE = ReplicatedReplacingMergeTree
ORDER BY (`from`, minute)
SETTINGS index_granularity = 524288; -- 64x larger

CREATE TABLE IF NOT EXISTS native_transfer_to_minutes ON CLUSTER 'tokenapis-a' (
    `to`                LowCardinality(String) COMMENT 'recipient address',
    minute              DateTime('UTC') COMMENT 'start minute of the transfers',
)
ENGINE = ReplicatedReplacingMergeTree
ORDER BY (`to`, minute)
SETTINGS index_granularity = 524288; -- 64x larger

CREATE TABLE IF NOT EXISTS native_transfer_tx_hash_timestamps ON CLUSTER 'tokenapis-a' (
    tx_hash             String COMMENT 'transaction hash',
    timestamp           DateTime('UTC') COMMENT 'timestamp of transfers',
)
ENGINE = ReplicatedReplacingMergeTree
ORDER BY (tx_hash, timestamp)
SETTINGS index_granularity = 2048; -- 0.25x smaller

CREATE TABLE IF NOT EXISTS native_transfer_block_hash_timestamps ON CLUSTER 'tokenapis-a' (
    block_hash          String COMMENT 'block hash',
    timestamp           DateTime('UTC') COMMENT 'timestamp of transfers',
)
ENGINE = ReplicatedReplacingMergeTree
ORDER BY (block_hash, timestamp)
SETTINGS index_granularity = 2048; -- 0.25x smaller

-- from -- minute MV
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_native_transfer_from_minutes ON CLUSTER 'tokenapis-a'
TO native_transfer_from_minutes
AS
SELECT `from`, toStartOfMinute(timestamp) AS minute
FROM native_transfer
GROUP BY `from`, minute;

-- to -- minute MV
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_native_transfer_to_minutes ON CLUSTER 'tokenapis-a'
TO native_transfer_to_minutes
AS
SELECT `to`, toStartOfMinute(timestamp) AS minute
FROM native_transfer
GROUP BY `to`, minute;

-- tx_hash -- timestamp MV
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_native_transfer_tx_hash_timestamps ON CLUSTER 'tokenapis-a'
TO native_transfer_tx_hash_timestamps
AS
SELECT tx_hash, timestamp
FROM native_transfer
GROUP BY tx_hash, timestamp;

-- block_hash -- timestamp MV
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_native_transfer_block_hash_timestamps ON CLUSTER 'tokenapis-a'
TO native_transfer_block_hash_timestamps
AS
SELECT block_hash, timestamp
FROM native_transfer
GROUP BY block_hash, timestamp;