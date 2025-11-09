-- TRC20 Transfer Logs --
CREATE TABLE IF NOT EXISTS trc20_transfer AS TEMPLATE_LOG
COMMENT 'TRC20 Token Transfer events from logs';
ALTER TABLE trc20_transfer
    -- transfer event information --
    ADD COLUMN IF NOT EXISTS `from`        String,
    ADD COLUMN IF NOT EXISTS `to`          String,
    ADD COLUMN IF NOT EXISTS amount        UInt256,

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_amount (amount) TYPE minmax GRANULARITY 1;