-- Table for TRC20 transfer summarized
CREATE TABLE IF NOT EXISTS trc20_transfer_sum (
    -- order keys --
    log_address         LowCardinality(String) COMMENT 'token contract address',
    `from`              String COMMENT 'sender address',
    `to`                String COMMENT 'recipient address',
    minute              DateTime('UTC') COMMENT 'start of the minute of the transfers',

    -- transfers --
    transactions        UInt64 COMMENT 'Total number of transfers between from->to in this minute',
    amount              UInt256 COMMENT 'Total amount transferred between from->to in this minute',

    -- projections --
    PROJECTION prj_log_address_by_minute ( SELECT log_address, minute, sum(transactions), sum(amount) GROUP BY (log_address, minute) ),
    PROJECTION prj_from_by_minute ( SELECT `from`, minute, sum(transactions), sum(amount) GROUP BY (`from`, minute) ),
    PROJECTION prj_to_by_minute ( SELECT `to`, minute, sum(transactions), sum(amount) GROUP BY (`to`, minute) )
)
ENGINE = SummingMergeTree
ORDER BY (log_address, `from`, `to`, minute)
COMMENT 'TRC20 Token Transfer summarized';

-- -- Projections --
-- ALTER TABLE trc20_transfer_sum
--     MODIFY SETTING deduplicate_merge_projection_mode = 'rebuild';

-- -- projections by timestamp --
-- -- helpful for filtering by time ranges --
-- ALTER TABLE trc20_transfer_sum
--     ADD PROJECTION IF NOT EXISTS prj_log_address_by_minute ( SELECT log_address, minute, sum(transactions), sum(amount) GROUP BY (log_address, minute) ),
--     ADD PROJECTION IF NOT EXISTS prj_from_by_minute ( SELECT `from`, minute, sum(transactions), sum(amount) GROUP BY (`from`, minute) ),
--     ADD PROJECTION IF NOT EXISTS prj_to_by_minute ( SELECT `to`, minute, sum(transactions), sum(amount) GROUP BY (`to`, minute) )

-- Materialized view for TRC20 transfer summary
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_sum
TO trc20_transfer_sum
AS
-- +credits: to-account receives amount
SELECT
    -- order keys --
    log_address,
    `from`,
    `to`,
    toStartOfMinute(timestamp) AS minute,

    -- transfers --
    sum(amount) as amount,
    count() AS transactions
FROM trc20_transfer
GROUP BY log_address, `from`, `to`, minute