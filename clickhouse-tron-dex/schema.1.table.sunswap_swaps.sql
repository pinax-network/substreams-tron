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
    ADD COLUMN IF NOT EXISTS token0           String COMMENT 'Token0 contract address',
    ADD COLUMN IF NOT EXISTS token1           String COMMENT 'Token1 contract address',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_sender (sender) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_to (to) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_amount0_in (amount0_in) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_amount1_in (amount1_in) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_amount0_out (amount0_out) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_amount1_out (amount1_out) TYPE minmax GRANULARITY 1;
