-- Table for Native transfer minutes
-- used for optimizing queries that need to filter by minute intervals
CREATE TABLE IF NOT EXISTS native_transfer_minutes (
    -- order keys --
    `from`              String COMMENT 'from sender address',
    `to`                String COMMENT 'to receiver address',
    minute              DateTime('UTC') COMMENT 'start minute of the transfers',
)
ENGINE = ReplacingMergeTree
ORDER BY (`from`, `to`, minute);

-- Settings and projections --
ALTER TABLE native_transfer_minutes
    MODIFY SETTING deduplicate_merge_projection_mode = 'rebuild';
ALTER TABLE native_transfer_minutes
    -- projections --
    -- optimize single group by minute queries --
    ADD PROJECTION IF NOT EXISTS prj_from_minutes ( SELECT `from`, minute, count() GROUP BY `from`, minute ),
    ADD PROJECTION IF NOT EXISTS prj_to_minutes ( SELECT `to`, minute, count() GROUP BY `to`, minute );

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_native_transfer_minutes
TO native_transfer_minutes
AS
SELECT
    `from`,
    `to`,
    toStartOfMinute(timestamp) AS minute
FROM native_transfer
GROUP BY
    `from`,
    `to`,
    minute;