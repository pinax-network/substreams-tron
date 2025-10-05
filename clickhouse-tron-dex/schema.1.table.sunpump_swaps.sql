-- SunPump Swaps --
CREATE TABLE IF NOT EXISTS sunpump_swaps AS TEMPLATE_LOG
COMMENT 'SunPump TokenPurchased and TokenSold swap events';
ALTER TABLE sunpump_swaps
    -- swap event information --
    ADD COLUMN IF NOT EXISTS user              String COMMENT 'User wallet address (buyer/seller)',
    ADD COLUMN IF NOT EXISTS token             LowCardinality(String) COMMENT 'Token contract address',
    ADD COLUMN IF NOT EXISTS pool              LowCardinality(String) COMMENT 'SunPump pool contract address',
    ADD COLUMN IF NOT EXISTS input_contract    LowCardinality(String) COMMENT 'Input token contract address (TRX or token)',
    ADD COLUMN IF NOT EXISTS input_amount      UInt256 COMMENT 'Amount of input tokens swapped',
    ADD COLUMN IF NOT EXISTS output_contract   LowCardinality(String) COMMENT 'Output token contract address (token or TRX)',
    ADD COLUMN IF NOT EXISTS output_amount     UInt256 COMMENT 'Amount of output tokens received',
    ADD COLUMN IF NOT EXISTS fee               UInt256 COMMENT 'Swap fee amount',
    ADD COLUMN IF NOT EXISTS token_reserve     UInt256 COMMENT 'Token reserve after swap (only for purchases)',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_user (user) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token (token) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_pool (pool) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_input_contract (input_contract) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_output_contract (output_contract) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_input_amount (input_amount) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_output_amount (output_amount) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_fee (fee) TYPE minmax GRANULARITY 1;
