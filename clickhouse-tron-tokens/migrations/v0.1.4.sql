CREATE TABLE IF NOT EXISTS native_transfer_sum ON CLUSTER 'tokenapis-a' (
    -- order keys --
    `from`              String COMMENT 'from sender address',
    `to`                String COMMENT 'to receiver address',
    minute              DateTime('UTC') COMMENT 'start minute of the transfers',

    -- transfers --
    transactions        UInt64 COMMENT 'Total number of transfers between from->to in this minute',
    amount              UInt256 COMMENT 'Total amount transferred between from->to in this minute',

    -- projections --
    -- used for optimizing queries that need to filter by minute intervals and get sums
    PROJECTION prj_from_by_minute ( SELECT `from`, minute, sum(transactions), sum(amount) GROUP BY `from`, minute ),
    PROJECTION prj_to_by_minute ( SELECT `to`, minute, sum(transactions), sum(amount) GROUP BY `to`, minute )
)
ENGINE = SummingMergeTree
ORDER BY (`from`, `to`, minute)
SETTINGS deduplicate_merge_projection_mode = 'rebuild';

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_native_transfer_sum ON CLUSTER 'tokenapis-a'
TO native_transfer_sum
AS
SELECT
    `from`,
    `to`,
    toStartOfMinute(timestamp) AS minute,
    sum(amount) AS amount,
    count() AS transactions
FROM native_transfer
GROUP BY
    `from`,
    `to`,
    minute;

-- Table for TRC20 transfer sums
-- used for optimizing queries that need to filter by minute intervals and get sums
CREATE TABLE IF NOT EXISTS trc20_transfer_sum ON CLUSTER 'tokenapis-a' (
    -- order keys --
    log_address         LowCardinality(String) COMMENT 'token contract address',
    `from`              String COMMENT 'from sender address',
    `to`                String COMMENT 'to receiver address',
    minute              DateTime('UTC') COMMENT 'start minute of the transfers',

    -- transfers --
    transactions        UInt64 COMMENT 'Total number of transfers between from->to in this minute',
    amount              UInt256 COMMENT 'Total amount transferred between from->to in this minute',

    -- projections --
    -- used for optimizing queries that need to filter by minute intervals and get sums

    -- single keys --
    PROJECTION prj_log_address_by_minute ( SELECT log_address, minute, sum(transactions), sum(amount) GROUP BY log_address, minute ),
    PROJECTION prj_from_by_minute ( SELECT `from`, minute, sum(transactions), sum(amount) GROUP BY `from`, minute ),
    PROJECTION prj_to_by_minute ( SELECT `to`, minute, sum(transactions), sum(amount) GROUP BY `to`, minute ),

    -- log_address + from/to --
    PROJECTION prj_log_address_from_by_minute ( SELECT log_address, `from`, minute, sum(transactions), sum(amount) GROUP BY log_address, `from`, minute ),
    PROJECTION prj_log_address_to_by_minute ( SELECT log_address, `to`, minute, sum(transactions), sum(amount) GROUP BY log_address, `to`, minute)
)
ENGINE = SummingMergeTree
ORDER BY (log_address, `from`, `to`, minute)
SETTINGS deduplicate_merge_projection_mode = 'rebuild';

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_sum ON CLUSTER 'tokenapis-a'
TO trc20_transfer_sum
AS
SELECT
    log_address,
    `from`,
    `to`,
    toStartOfMinute(timestamp) AS minute,
    sum(amount) AS amount,
    count() AS transactions
FROM trc20_transfer
GROUP BY
    log_address,
    `from`,
    `to`,
    minute;


-- Backfill existing data into the new summing tables
INSERT INTO trc20_transfer_sum
SELECT
    log_address,
    `from`,
    `to`,
    toStartOfMinute(timestamp) AS minute,
    sum(amount) AS amount,
    count() AS transactions
FROM trc20_transfer
WHERE year(timestamp) = 2024
GROUP BY
    log_address,
    `from`,
    `to`,
    minute;

INSERT INTO native_transfer_sum
SELECT
    `from`,
    `to`,
    toStartOfMinute(timestamp) AS minute,
    sum(amount) AS amount,
    count() AS transactions
FROM native_transfer
WHERE year(timestamp) < 2023
GROUP BY
    `from`,
    `to`,
    minute;