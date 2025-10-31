-- TRC20 Transfer Logs --
CREATE TABLE IF NOT EXISTS trc20_transfer AS TEMPLATE_LOG
COMMENT 'TRC20 Token Transfer events from logs';
ALTER TABLE trc20_transfer
    -- transfer event information --
    ADD COLUMN IF NOT EXISTS `from`        String,
    ADD COLUMN IF NOT EXISTS `to`          String,
    ADD COLUMN IF NOT EXISTS amount        UInt256,

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_from (from) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_to (to) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_amount (amount) TYPE minmax GRANULARITY 1,

    -- projections (filters by minute) --
    ADD PROJECTION IF NOT EXISTS prj_log_address_by_relative_minute (SELECT log_address, toRelativeMinuteNum(timestamp) AS minute GROUP BY log_address, minute),
    ADD PROJECTION IF NOT EXISTS prj_from_by_relative_minute (SELECT `from`, toRelativeMinuteNum(timestamp) as minute GROUP BY `from`, minute),
    ADD PROJECTION IF NOT EXISTS prj_to_by_relative_minute (SELECT `to`, toRelativeMinuteNum(timestamp) as minute GROUP BY `to`, minute);
