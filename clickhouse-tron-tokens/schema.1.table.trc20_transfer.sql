-- TRC20 Transfer Logs --
CREATE TABLE IF NOT EXISTS trc20_transfer AS base_events
COMMENT 'TRC20 Token Transfer events from logs';
ALTER TABLE trc20_transfer
    -- log information --
    ADD COLUMN IF NOT EXISTS log_address            String,
    ADD COLUMN IF NOT EXISTS log_ordinal            UInt64,

    -- transfer event information --
    ADD COLUMN IF NOT EXISTS transfer_from          String,
    ADD COLUMN IF NOT EXISTS transfer_to            String,
    ADD COLUMN IF NOT EXISTS transfer_amount        String,

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_log_address (log_address) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_transfer_from (transfer_from) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_transfer_to (transfer_to) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_log_ordinal (log_ordinal) TYPE minmax GRANULARITY 1;