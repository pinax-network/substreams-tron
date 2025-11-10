-- Native transfer by minutes
-- Used for optimizing queries that need to filter by minute intervals
CREATE TABLE IF NOT EXISTS native_transfer_minutes ON CLUSTER 'tokenapis-a' (
    -- order keys --
    `from`              String COMMENT 'from sender address',
    `to`                String COMMENT 'to receiver address',
    minute              DateTime('UTC') COMMENT 'start minute of the transfers',

    -- projections --
    -- from / to --
    PROJECTION prj_from_by_minute ( SELECT `from`, minute, count() GROUP BY `from`, minute ),
    PROJECTION prj_to_by_minute ( SELECT `to`, minute, count() GROUP BY `to`, minute ),

    -- from + to --
    PROJECTION prj_to_from_by_minute ( SELECT `to`, `from`, minute, count() GROUP BY `to`, `from`, minute )
)
ENGINE = ReplicatedReplacingMergeTree
ORDER BY (`from`, `to`, minute)
SETTINGS deduplicate_merge_projection_mode = 'rebuild';

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_native_transfer_minutes ON CLUSTER 'tokenapis-a'
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