-- Table for TRC20 transfer minutes
-- used for optimizing queries that need to filter by minute intervals
CREATE TABLE IF NOT EXISTS trc20_transfer_minutes (
    -- order keys --
    log_address         LowCardinality(String) COMMENT 'token contract address',
    `from`              String COMMENT 'from sender address',
    `to`                String COMMENT 'to receiver address',

    -- intervals --
    minute              DateTime('UTC') COMMENT 'start minute of the transfers',
)
ENGINE = ReplacingMergeTree
ORDER BY (log_address, `from`, `to`, minute);

-- Settings and projections --
ALTER TABLE trc20_transfer_minutes
    MODIFY SETTING deduplicate_merge_projection_mode = 'rebuild';
ALTER TABLE trc20_transfer_minutes
    -- projections --
    -- single order key --
    ADD PROJECTION IF NOT EXISTS prj_log_address_minutes ( SELECT log_address, minute, count() GROUP BY log_address, minute ),
    ADD PROJECTION IF NOT EXISTS prj_from_minutes ( SELECT `from`, minute, count() GROUP BY `from`, minute ),
    ADD PROJECTION IF NOT EXISTS prj_to_minutes ( SELECT `to`, minute, count() GROUP BY `to`, minute ),

    -- combination keys --
    ADD PROJECTION IF NOT EXISTS prj_log_address_from_minutes ( SELECT log_address, `from`, minute, count() GROUP BY log_address, `from`, minute ),
    ADD PROJECTION IF NOT EXISTS prj_log_address_to_minutes ( SELECT log_address, `to`, minute, count() GROUP BY log_address, `to`, minute );

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_minutes
TO trc20_transfer_minutes
AS
SELECT
    log_address,
    `from`,
    `to`,
    toStartOfMinute(timestamp) AS minute
FROM trc20_transfer
GROUP BY
    log_address,
    `from`,
    `to`,
    minute;