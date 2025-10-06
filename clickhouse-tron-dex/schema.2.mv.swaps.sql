-- Swaps --
CREATE TABLE IF NOT EXISTS swaps AS TEMPLATE_LOG
COMMENT 'Swaps';
ALTER TABLE swaps
    -- swap event information --
    ADD COLUMN IF NOT EXISTS pool               LowCardinality(String) COMMENT 'Pool/exchange contract address',
    ADD COLUMN IF NOT EXISTS user               String COMMENT 'User wallet address',
    ADD COLUMN IF NOT EXISTS input_contract     LowCardinality(String) COMMENT 'Input token contract address',
    ADD COLUMN IF NOT EXISTS input_amount       UInt256 COMMENT 'Amount of input tokens swapped',
    ADD COLUMN IF NOT EXISTS output_contract    LowCardinality(String) COMMENT 'Output token contract address',
    ADD COLUMN IF NOT EXISTS output_amount      UInt256 COMMENT 'Amount of output tokens received',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_pool              (pool)              TYPE bloom_filter(0.005)    GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_user              (user)              TYPE bloom_filter(0.005)    GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_input_contract    (input_contract)    TYPE bloom_filter(0.005)    GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_output_contract   (output_contract)   TYPE bloom_filter(0.005)    GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_input_amount      (input_amount)      TYPE minmax                 GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_output_amount     (output_amount)     TYPE minmax                 GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_contract_pair     (input_contract, output_contract)       TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_contract_pair_inv (output_contract, input_contract)       TYPE bloom_filter(0.005) GRANULARITY 1;
