-- TRC20 Transfer Logs --
CREATE TABLE IF NOT EXISTS trc20_transfer AS TEMPLATE_LOG
COMMENT 'TRC20 Token Transfer events from logs';
ALTER TABLE trc20_transfer
    -- transfer event information --
    ADD COLUMN IF NOT EXISTS `from`        String,
    ADD COLUMN IF NOT EXISTS `to`          String,
    ADD COLUMN IF NOT EXISTS amount        UInt256,

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_amount (amount) TYPE minmax GRANULARITY 1,

    -- projections --
    -- used for WHERE from IN (...) AND minute IN (...) queries --
    -- from/to --
    ADD PROJECTION IF NOT EXISTS prj_from_by_minute ( SELECT `from`, date, hour, minute, count(), sum(amount) GROUP BY `from`, date, hour, minute ),
    ADD PROJECTION IF NOT EXISTS prj_to_by_minute ( SELECT `to`, date, hour, minute, count(), sum(amount) GROUP BY `to`, date, hour, minute ),

    -- log_address + from/to --
    ADD PROJECTION IF NOT EXISTS prj_log_address_from_by_minute ( SELECT log_address, `from`, date, hour, minute, count(), sum(amount) GROUP BY log_address, `from`, date, hour, minute ),
    ADD PROJECTION IF NOT EXISTS prj_log_address_to_by_minute ( SELECT log_address, `to`, date, hour, minute, count(), sum(amount) GROUP BY log_address, `to`, date, hour, minute ),

    -- log_address + from + to --
    ADD PROJECTION IF NOT EXISTS prj_log_address_from_to_by_minute ( SELECT log_address, `from`, `to`, date, hour, minute, count(), sum(amount) GROUP BY log_address, `from`, `to`, date, hour, minute ),
    ADD PROJECTION IF NOT EXISTS prj_log_address_to_from_by_minute ( SELECT log_address, `to`, `from`, date, hour, minute, count(), sum(amount) GROUP BY log_address, `to`, `from`, date, hour, minute );