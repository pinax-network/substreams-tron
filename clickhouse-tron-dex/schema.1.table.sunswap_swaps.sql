-- SunSwap Swaps --
CREATE TABLE IF NOT EXISTS sunswap_swaps AS TEMPLATE_LOG
COMMENT 'SunSwap V2 Swap events';
ALTER TABLE sunswap_swaps
    -- swap event information --
    ADD COLUMN IF NOT EXISTS sender            String COMMENT 'Transaction sender address',
    ADD COLUMN IF NOT EXISTS `to`              String COMMENT 'Recipient address',
    ADD COLUMN IF NOT EXISTS pool              LowCardinality(String) COMMENT 'SunSwap pool contract address',
    ADD COLUMN IF NOT EXISTS input_contract    LowCardinality(String) COMMENT 'Input token identifier (token0/token1)',
    ADD COLUMN IF NOT EXISTS input_amount      UInt256 COMMENT 'Amount of input tokens swapped',
    ADD COLUMN IF NOT EXISTS output_contract   LowCardinality(String) COMMENT 'Output token identifier (token0/token1)',
    ADD COLUMN IF NOT EXISTS output_amount     UInt256 COMMENT 'Amount of output tokens received',
    
    -- raw amounts for reference --
    ADD COLUMN IF NOT EXISTS amount0_in        UInt256 COMMENT 'Amount of token0 input',
    ADD COLUMN IF NOT EXISTS amount1_in        UInt256 COMMENT 'Amount of token1 input',
    ADD COLUMN IF NOT EXISTS amount0_out       UInt256 COMMENT 'Amount of token0 output',
    ADD COLUMN IF NOT EXISTS amount1_out       UInt256 COMMENT 'Amount of token1 output',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_sender (sender) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_to (to) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_pool (pool) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_input_contract (input_contract) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_output_contract (output_contract) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_input_amount (input_amount) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_output_amount (output_amount) TYPE minmax GRANULARITY 1;
