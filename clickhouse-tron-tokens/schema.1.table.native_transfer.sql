-- Native TRX Transfer Transactions --
CREATE TABLE IF NOT EXISTS native_transfer AS TEMPLATE_TRANSACTION
COMMENT 'Native TRX Transfer events from transactions';
ALTER TABLE native_transfer
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
    ADD PROJECTION IF NOT EXISTS prj_from_to_count ( SELECT `from`, `to`, count() GROUP BY `from`, `to` ),
    ADD PROJECTION IF NOT EXISTS prj_to_from_count ( SELECT `to`, `from`, count() GROUP BY `to`, `from` ),

    -- minute: from | to --
    ADD PROJECTION IF NOT EXISTS prj_from_by_minute ( SELECT `from`, minute, count() GROUP BY `from`, minute ),
    ADD PROJECTION IF NOT EXISTS prj_to_by_minute ( SELECT `to`, minute, count() GROUP BY `to`, minute ),

    -- minute: from + to --
    ADD PROJECTION IF NOT EXISTS prj_to_from_by_minute ( SELECT `to`, `from`, minute, count() GROUP BY `to`, `from`, minute );
