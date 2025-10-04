-- JustSwap Swaps --
CREATE TABLE IF NOT EXISTS justswap_swaps AS TEMPLATE_LOG
COMMENT 'JustSwap V1 TokenPurchase and TrxPurchase swap events';
ALTER TABLE justswap_swaps
    -- swap event information --
    ADD COLUMN IF NOT EXISTS user              String COMMENT 'User wallet address',
    ADD COLUMN IF NOT EXISTS pool              LowCardinality(String) COMMENT 'JustSwap pool/exchange contract address',
    ADD COLUMN IF NOT EXISTS input_contract    LowCardinality(String) COMMENT 'Input token contract address (TRX or token)',
    ADD COLUMN IF NOT EXISTS input_amount      UInt256 COMMENT 'Amount of input tokens swapped',
    ADD COLUMN IF NOT EXISTS output_contract   LowCardinality(String) COMMENT 'Output token contract address (token or TRX)',
    ADD COLUMN IF NOT EXISTS output_amount     UInt256 COMMENT 'Amount of output tokens received',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_user (user) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_pool (pool) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_input_contract (input_contract) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_output_contract (output_contract) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_input_amount (input_amount) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_output_amount (output_amount) TYPE minmax GRANULARITY 1;
