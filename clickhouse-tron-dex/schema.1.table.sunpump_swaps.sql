-- SunPump TokenPurchased --
CREATE TABLE IF NOT EXISTS sunpump_token_purchased AS TEMPLATE_LOG
COMMENT 'SunPump TokenPurchased and TokenSold swap events';
ALTER TABLE sunpump_token_purchased
    -- swap event information --
    ADD COLUMN IF NOT EXISTS buyer                  String COMMENT 'User wallet address',
    ADD COLUMN IF NOT EXISTS trx_amount             UInt256 COMMENT 'Amount of input tokens swapped',
    ADD COLUMN IF NOT EXISTS token                  LowCardinality(String) COMMENT 'Token contract address',
    ADD COLUMN IF NOT EXISTS token_amount           UInt256 COMMENT 'Amount of output tokens received',
    ADD COLUMN IF NOT EXISTS fee                    UInt256 COMMENT 'Swap fee amount',
    ADD COLUMN IF NOT EXISTS token_reserve          UInt256 COMMENT 'Token reserve after swap (only for purchases)',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_buyer (buyer) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_trx_amount (trx_amount) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token (token) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token_amount (token_amount) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_fee (fee) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token_reserve (token_reserve) TYPE minmax GRANULARITY 1;

-- SunPump TokenSold --
CREATE TABLE IF NOT EXISTS sunpump_token_sold AS TEMPLATE_LOG
COMMENT 'SunPump TokenPurchased and TokenSold swap events';
ALTER TABLE sunpump_token_sold
    -- swap event information --
    ADD COLUMN IF NOT EXISTS seller             String COMMENT 'User wallet address',
    ADD COLUMN IF NOT EXISTS token              LowCardinality(String) COMMENT 'Token contract address',
    ADD COLUMN IF NOT EXISTS token_amount       UInt256 COMMENT 'Amount of output tokens received',
    ADD COLUMN IF NOT EXISTS trx_amount         UInt256 COMMENT 'Amount of input tokens swapped',
    ADD COLUMN IF NOT EXISTS fee                UInt256 COMMENT 'Swap fee amount',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_seller (seller) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token (token) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token_amount (token_amount) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_trx_amount (trx_amount) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_fee (fee) TYPE minmax GRANULARITY 1;
