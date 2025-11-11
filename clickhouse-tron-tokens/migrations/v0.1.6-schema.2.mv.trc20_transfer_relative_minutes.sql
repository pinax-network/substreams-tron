-- TRC20 transfer by minutes
-- used for optimizing queries that need to filter by minute intervals
CREATE TABLE IF NOT EXISTS trc20_transfer_relative_minutes (
    -- order keys --
    log_address         LowCardinality(String) COMMENT 'token contract address',
    `from`              String COMMENT 'from sender address',
    `to`                String COMMENT 'to receiver address',
    minute              UInt32 COMMENT 'toRelativeMinuteNum(timestamp) of the transfers',

    -- projections --
    -- log_address / from / to --
    PROJECTION prj_log_address_by_minute ( SELECT log_address, minute, count() GROUP BY log_address, minute ),
    PROJECTION prj_from_by_minute ( SELECT `from`, minute, count() GROUP BY `from`, minute ),
    PROJECTION prj_to_by_minute ( SELECT `to`, minute, count() GROUP BY `to`, minute ),

    -- log_address + from / to --
    PROJECTION prj_log_address_from_by_minute ( SELECT log_address, `from`, minute, count() GROUP BY log_address, `from`, minute ),
    PROJECTION prj_log_address_to_by_minute ( SELECT log_address, `to`, minute, count() GROUP BY log_address, `to`, minute),

    -- log_address + to + from --
    PROJECTION prj_log_address_to_from_by_minute ( SELECT log_address, `to`, `from`, minute, count() GROUP BY log_address, `to`, `from`, minute )
)
ENGINE = ReplacingMergeTree
ORDER BY (log_address, `from`, `to`, minute)
SETTINGS deduplicate_merge_projection_mode = 'rebuild';

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_relative_minutes
TO trc20_transfer_relative_minutes
AS
SELECT
    log_address,
    `from`,
    `to`,
    toRelativeMinuteNum(timestamp) AS minute
FROM trc20_transfer
GROUP BY
    log_address,
    `from`,
    `to`,
    minute;
