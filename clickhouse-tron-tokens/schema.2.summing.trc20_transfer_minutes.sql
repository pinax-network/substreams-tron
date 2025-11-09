-- Table for TRC20 transfer sums
-- used for optimizing queries that need to filter by minute intervals and get sums
CREATE TABLE IF NOT EXISTS trc20_transfer_sum (
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

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_sum
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