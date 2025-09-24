-- Native TRX Transfer Transactions --
CREATE TABLE IF NOT EXISTS native_transfer AS TEMPLATE_TRANSACTION
COMMENT 'Native TRX Transfer events from transactions';
ALTER TABLE native_transfer
    -- transfer information --
    ADD COLUMN IF NOT EXISTS `from`        String,
    ADD COLUMN IF NOT EXISTS `to`          String,
    ADD COLUMN IF NOT EXISTS amount        UInt256,

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_from (`from`) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_to (`to`) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_amount (amount) TYPE minmax GRANULARITY 1;