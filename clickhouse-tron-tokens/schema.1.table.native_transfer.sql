-- Native TRX Transfer Transactions --
CREATE TABLE IF NOT EXISTS native_transfer AS base_events
COMMENT 'Native TRX Transfer events from transactions';
ALTER TABLE native_transfer
    -- transfer information --
    ADD COLUMN IF NOT EXISTS transfer_from          String,
    ADD COLUMN IF NOT EXISTS transfer_to            String,
    ADD COLUMN IF NOT EXISTS transfer_amount        String,

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_transfer_from (transfer_from) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_transfer_to (transfer_to) TYPE bloom_filter(0.005) GRANULARITY 1;