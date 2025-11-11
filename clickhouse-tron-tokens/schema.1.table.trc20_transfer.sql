-- TRC20 Transfer Logs --
CREATE TABLE IF NOT EXISTS trc20_transfer AS TEMPLATE_LOG
COMMENT 'TRC20 Token Transfer events from logs';
ALTER TABLE trc20_transfer
    -- transfer --
    ADD COLUMN IF NOT EXISTS `from`        String,
    ADD COLUMN IF NOT EXISTS `to`          String,
    ADD COLUMN IF NOT EXISTS amount        UInt256,

    -- INDEXES --
    ADD INDEX IF NOT EXISTS idx_amount (amount) TYPE minmax GRANULARITY 1,

    -- PROJECTIONS --
    -- count() --
    ADD PROJECTION IF NOT EXISTS prj_from_count ( SELECT `from`, count() GROUP BY `from` ),
    ADD PROJECTION IF NOT EXISTS prj_to_count ( SELECT `to`, count() GROUP BY `to` ),
    ADD PROJECTION IF NOT EXISTS prj_to_from_count ( SELECT `to`, `from`, count() GROUP BY `to`, `from` ),
    ADD PROJECTION IF NOT EXISTS prj_from_to_count ( SELECT `from`, `to`, count() GROUP BY `from`, `to` ),
    ADD PROJECTION IF NOT EXISTS prj_log_address_from_count ( SELECT log_address, `from`, count() GROUP BY log_address, `from` ),
    ADD PROJECTION IF NOT EXISTS prj_log_address_to_count ( SELECT log_address, `to`, count() GROUP BY log_address, `to` ),
    ADD PROJECTION IF NOT EXISTS prj_log_address_to_from_count ( SELECT log_address, `from`, `to`, count() GROUP BY log_address, `from`, `to` ),
    ADD PROJECTION IF NOT EXISTS prj_log_address_from_to_count ( SELECT log_address, `to`, `from`, count() GROUP BY log_address, `to`, `from` ),

    -- minute: log_address | from | to --
    ADD PROJECTION IF NOT EXISTS prj_log_address_by_minute ( SELECT log_address, minute, count() GROUP BY log_address, minute ),
    ADD PROJECTION IF NOT EXISTS prj_from_by_minute ( SELECT `from`, minute, count() GROUP BY `from`, minute ),
    ADD PROJECTION IF NOT EXISTS prj_to_by_minute ( SELECT `to`, minute, count() GROUP BY `to`, minute ),

    -- minute: log_address + from | to --
    ADD PROJECTION IF NOT EXISTS prj_log_address_from_by_minute ( SELECT log_address, `from`, minute, count() GROUP BY log_address, `from`, minute ),
    ADD PROJECTION IF NOT EXISTS prj_log_address_to_by_minute ( SELECT log_address, `to`, minute, count() GROUP BY log_address, `to`, minute),

    -- minute: log_address + to + from --
    ADD PROJECTION IF NOT EXISTS prj_log_address_from_to_by_minute ( SELECT log_address, `from`, `to`, minute, count() GROUP BY log_address, `from`, `to`, minute );
