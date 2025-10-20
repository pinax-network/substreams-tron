-- SunSwap Swaps --
CREATE TABLE IF NOT EXISTS sunswap_swap AS TEMPLATE_LOG
COMMENT 'SunSwap V2 Swap events';
ALTER TABLE sunswap_swap
    -- swap event information --
    ADD COLUMN IF NOT EXISTS sender            String COMMENT 'Transaction sender address',
    ADD COLUMN IF NOT EXISTS `to`              String COMMENT 'Recipient address',

    -- raw amounts for reference --
    ADD COLUMN IF NOT EXISTS amount0_in        UInt256 COMMENT 'Amount of token0 input',
    ADD COLUMN IF NOT EXISTS amount1_in        UInt256 COMMENT 'Amount of token1 input',
    ADD COLUMN IF NOT EXISTS amount0_out       UInt256 COMMENT 'Amount of token0 output',
    ADD COLUMN IF NOT EXISTS amount1_out       UInt256 COMMENT 'Amount of token1 output',

    -- PairCreated --
    ADD COLUMN IF NOT EXISTS pair             String COMMENT 'Pair contract address',
    ADD COLUMN IF NOT EXISTS factory          String COMMENT 'Factory contract address',
    ADD COLUMN IF NOT EXISTS token0           String COMMENT 'Token0 contract address',
    ADD COLUMN IF NOT EXISTS token1           String COMMENT 'Token1 contract address',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_sender (sender) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_to (to) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_pair (pair) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_factory (factory) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token0 (token0) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token1 (token1) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_amount0_in (amount0_in) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_amount1_in (amount1_in) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_amount0_out (amount0_out) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_amount1_out (amount1_out) TYPE minmax GRANULARITY 1;

-- SunSwap PairCreated --
CREATE TABLE IF NOT EXISTS sunswap_pair_created AS TEMPLATE_LOG
COMMENT 'SunSwap V2 PairCreated events';
ALTER TABLE sunswap_pair_created
    -- PairCreated event information --
    ADD COLUMN IF NOT EXISTS token0           String COMMENT 'Token0 contract address',
    ADD COLUMN IF NOT EXISTS token1           String COMMENT 'Token1 contract address',
    ADD COLUMN IF NOT EXISTS pair             String COMMENT 'Pair contract address',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_token0 (token0) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token1 (token1) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_pair (pair) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token_pair (token0, token1) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token_pair_inv (token1, token0) TYPE bloom_filter GRANULARITY 1;