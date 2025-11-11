-- TRC20 transfer by minutes
-- used for optimizing queries that need to filter by minute intervals
-- `index_granularity` values are chosen to balance compression and query performance
CREATE TABLE IF NOT EXISTS trc20_transfer_log_address_minutes (
    log_address         LowCardinality(String) COMMENT 'token contract address',
    minute              DateTime('UTC') COMMENT 'start minute of the transfers',
)
ENGINE = ReplacingMergeTree
ORDER BY (log_address, minute)
SETTINGS index_granularity = 1048576; -- 128x larger

CREATE TABLE IF NOT EXISTS trc20_transfer_from_minutes (
    `from`              LowCardinality(String) COMMENT 'sender address',
    minute              DateTime('UTC') COMMENT 'start minute of the transfers',
)
ENGINE = ReplacingMergeTree
ORDER BY (`from`, minute)
SETTINGS index_granularity = 524288; -- 64x larger

CREATE TABLE IF NOT EXISTS trc20_transfer_to_minutes (
    `to`                LowCardinality(String) COMMENT 'recipient address',
    minute              DateTime('UTC') COMMENT 'start minute of the transfers',
)
ENGINE = ReplacingMergeTree
ORDER BY (`to`, minute)
SETTINGS index_granularity = 524288; -- 64x larger

CREATE TABLE IF NOT EXISTS trc20_transfer_tx_hash_timestamps (
    tx_hash             String COMMENT 'transaction hash',
    timestamp           DateTime('UTC') COMMENT 'timestamp of transfers',
)
ENGINE = ReplacingMergeTree
ORDER BY (tx_hash, timestamp)
SETTINGS index_granularity = 2048; -- 0.25x smaller

CREATE TABLE IF NOT EXISTS trc20_transfer_block_hash_timestamps (
    block_hash          String COMMENT 'block hash',
    timestamp           DateTime('UTC') COMMENT 'timestamp of transfers',
)
ENGINE = ReplacingMergeTree
ORDER BY (block_hash, timestamp)
SETTINGS index_granularity = 2048; -- 0.25x smaller

-- log_address -- minute MV
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_log_address_minutes
TO trc20_transfer_log_address_minutes
AS
SELECT log_address, toStartOfMinute(timestamp) AS minute
FROM trc20_transfer
GROUP BY log_address, minute;

-- from -- minute MV
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_from_minutes
TO trc20_transfer_from_minutes
AS
SELECT `from`, toStartOfMinute(timestamp) AS minute
FROM trc20_transfer
GROUP BY `from`, minute;

-- to -- minute MV
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_to_minutes
TO trc20_transfer_to_minutes
AS
SELECT `to`, toStartOfMinute(timestamp) AS minute
FROM trc20_transfer
GROUP BY `to`, minute;

-- tx_hash -- timestamp MV
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_tx_hash_timestamps
TO trc20_transfer_tx_hash_timestamps
AS
SELECT tx_hash, timestamp
FROM trc20_transfer
GROUP BY tx_hash, timestamp;

-- block_hash -- timestamp MV
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_block_hash_timestamps
TO trc20_transfer_block_hash_timestamps
AS
SELECT block_hash, timestamp
FROM trc20_transfer
GROUP BY block_hash, timestamp;