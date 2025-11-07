-- Native TRX Transfer Transactions --
CREATE TABLE IF NOT EXISTS native_transfer AS TEMPLATE_TRANSACTION
COMMENT 'Native TRX Transfer events from transactions';
ALTER TABLE native_transfer
    -- transfer information --
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

    -- from + to --
    ADD PROJECTION IF NOT EXISTS prj_from_to ( SELECT `from`, `to`, date, hour, minute, count(), sum(amount) GROUP BY `from`, `to`, date, hour, minute ),
    ADD PROJECTION IF NOT EXISTS prj_to_from ( SELECT `to`, `from`, date, hour, minute, count(), sum(amount) GROUP BY `to`, `from`, date, hour, minute );