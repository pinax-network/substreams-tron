-- Swaps --
CREATE TABLE IF NOT EXISTS swaps AS TEMPLATE_LOG
COMMENT 'Swaps';
ALTER TABLE swaps
    -- swap event information --
    ADD COLUMN IF NOT EXISTS factory            LowCardinality(String) COMMENT 'Factory contract address',
    ADD COLUMN IF NOT EXISTS pool               LowCardinality(String) COMMENT 'Pool/exchange contract address',
    ADD COLUMN IF NOT EXISTS user               String COMMENT 'User wallet address',
    ADD COLUMN IF NOT EXISTS input_contract     LowCardinality(String) COMMENT 'Input token contract address',
    ADD COLUMN IF NOT EXISTS input_amount       UInt256 COMMENT 'Amount of input tokens swapped',
    ADD COLUMN IF NOT EXISTS output_contract    LowCardinality(String) COMMENT 'Output token contract address',
    ADD COLUMN IF NOT EXISTS output_amount      UInt256 COMMENT 'Amount of output tokens received',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_factory           (factory)           TYPE bloom_filter    GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_pool              (pool)              TYPE bloom_filter    GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_user              (user)              TYPE bloom_filter    GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_input_contract    (input_contract)    TYPE bloom_filter    GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_output_contract   (output_contract)   TYPE bloom_filter    GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_input_amount      (input_amount)      TYPE minmax          GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_output_amount     (output_amount)     TYPE minmax          GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_contract_pair     (input_contract, output_contract)       TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_contract_pair_inv (output_contract, input_contract)       TYPE bloom_filter GRANULARITY 1,

    -- projections --
    ADD PROJECTION IF NOT EXISTS prj_factory (SELECT factory, timestamp, _part_offset ORDER BY (factory, timestamp)),
    ADD PROJECTION IF NOT EXISTS prj_pool (SELECT pool, timestamp, _part_offset ORDER BY (pool, timestamp)),
    ADD PROJECTION IF NOT EXISTS prj_user (SELECT user, timestamp, _part_offset ORDER BY (user, timestamp)),
    ADD PROJECTION IF NOT EXISTS prj_input_contract (SELECT input_contract, timestamp, _part_offset ORDER BY (input_contract, timestamp)),
    ADD PROJECTION IF NOT EXISTS prj_output_contract (SELECT output_contract, timestamp, _part_offset ORDER BY (output_contract, timestamp))
    ADD PROJECTION IF NOT EXISTS prj_contract_pair (SELECT input_contract, output_contract, timestamp, _part_offset ORDER BY (input_contract, output_contract, timestamp)),
    ADD PROJECTION IF NOT EXISTS prj_contract_pair_inv (SELECT output_contract, input_contract, timestamp, _part_offset ORDER BY (output_contract, input_contract, timestamp));


CREATE MATERIALIZED VIEW IF NOT EXISTS mv_sunswap_swap
TO swaps AS
SELECT
    -- include everything from sunswap_swap except the non-relevant fields
    * EXCEPT (
        sender,
        `to`,
        amount0_in,
        amount1_in,
        amount0_out,
        amount1_out,
        token0,
        token1,
        pair
    ),

    -- mapped swap fields
    pair                               AS pool,
    sender                             AS user,

    -- Input side
    if (amount0_in > toUInt256(0), token0, token1)      AS input_contract,
    if (amount0_in > toUInt256(0), amount0_in, amount1_in) AS input_amount,

    -- Output side
    if (amount0_in > toUInt256(0), token1, token0)      AS output_contract,
    if (amount0_in > toUInt256(0), amount1_out, amount0_out) AS output_amount

FROM sunswap_swap;