-- Table for Native transfer sums
-- used for optimizing queries that need to filter by minute intervals and get sums
CREATE TABLE IF NOT EXISTS native_transfer_sum (
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

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_native_transfer_sum
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