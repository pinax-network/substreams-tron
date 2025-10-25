-- Swaps --
CREATE TABLE IF NOT EXISTS swaps AS TEMPLATE_LOG
COMMENT 'Swaps';
ALTER TABLE swaps
    -- swap event information --
    ADD COLUMN IF NOT EXISTS protocol           LowCardinality(String) COMMENT 'DEX protocol name',
    ADD COLUMN IF NOT EXISTS factory            LowCardinality(String) COMMENT 'Factory contract address',
    ADD COLUMN IF NOT EXISTS pool               LowCardinality(String) COMMENT 'Pool/exchange contract address',
    ADD COLUMN IF NOT EXISTS user               String COMMENT 'User wallet address',
    ADD COLUMN IF NOT EXISTS input_contract     LowCardinality(String) COMMENT 'Input token contract address',
    ADD COLUMN IF NOT EXISTS input_amount       UInt256 COMMENT 'Amount of input tokens swapped',
    ADD COLUMN IF NOT EXISTS output_contract    LowCardinality(String) COMMENT 'Output token contract address',
    ADD COLUMN IF NOT EXISTS output_amount      UInt256 COMMENT 'Amount of output tokens received',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_protocol          (protocol)          TYPE set(4)          GRANULARITY 1,
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
    ADD PROJECTION IF NOT EXISTS prj_protocol (SELECT protocol, timestamp, _part_offset ORDER BY (protocol, timestamp)),
    ADD PROJECTION IF NOT EXISTS prj_factory (SELECT factory, timestamp, _part_offset ORDER BY (factory, timestamp)),
    ADD PROJECTION IF NOT EXISTS prj_pool (SELECT pool, timestamp, _part_offset ORDER BY (pool, timestamp)),
    ADD PROJECTION IF NOT EXISTS prj_user (SELECT user, timestamp, _part_offset ORDER BY (user, timestamp)),
    ADD PROJECTION IF NOT EXISTS prj_input_contract (SELECT input_contract, timestamp, _part_offset ORDER BY (input_contract, timestamp)),
    ADD PROJECTION IF NOT EXISTS prj_output_contract (SELECT output_contract, timestamp, _part_offset ORDER BY (output_contract, timestamp)),
    ADD PROJECTION IF NOT EXISTS prj_contract_pair (SELECT input_contract, output_contract, timestamp, _part_offset ORDER BY (input_contract, output_contract, timestamp)),
    ADD PROJECTION IF NOT EXISTS prj_contract_pair_inv (SELECT output_contract, input_contract, timestamp, _part_offset ORDER BY (output_contract, input_contract, timestamp));


CREATE MATERIALIZED VIEW IF NOT EXISTS mv_sunswap_swap
TO swaps AS
SELECT
    'sunswap' AS protocol,
    -- include everything from sunswap_swap except the non-relevant fields
    * EXCEPT (
        sender,
        `to`,
        amount0_in,
        amount1_in,
        amount0_out,
        amount1_out,
        token0,
        token1
    ),

    -- mapped swap fields
    log_address                        AS pool,
    sender                             AS user,

    -- Input side
    if (amount0_in > toUInt256(0), token0, token1)      AS input_contract,
    if (amount0_in > toUInt256(0), amount0_in, amount1_in) AS input_amount,

    -- Output side
    if (amount0_in > toUInt256(0), token1, token0)      AS output_contract,
    if (amount0_in > toUInt256(0), amount1_out, amount0_out) AS output_amount

FROM sunswap_swap;


-- JustSwap TokenPurchase: User buys tokens with TRX (TRX → Token)
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_justswap_token_purchase
TO swaps AS
SELECT
    'justswap' AS protocol,
    -- include everything from justswap_token_purchase except the non-relevant fields
    * EXCEPT (
        buyer,
        trx_sold,
        tokens_bought,
        token
    ),

    -- mapped swap fields
    log_address                        AS pool,
    buyer                              AS user,

    -- Input side: TRX being sold
    'T0000000000000000000000000000000000000001'                                 AS input_contract,  -- TRX native asset
    trx_sold                           AS input_amount,

    -- Output side: Tokens being bought
    token                              AS output_contract,
    tokens_bought                      AS output_amount

FROM justswap_token_purchase;


-- JustSwap TrxPurchase: User buys TRX with tokens (Token → TRX)
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_justswap_trx_purchase
TO swaps AS
SELECT
    'justswap' AS protocol,
    -- include everything from justswap_trx_purchase except the non-relevant fields
    * EXCEPT (
        buyer,
        tokens_sold,
        trx_bought,
        token
    ),

    -- mapped swap fields
    log_address                        AS pool,
    buyer                              AS user,

    -- Input side: Tokens being sold
    token                              AS input_contract,
    tokens_sold                        AS input_amount,

    -- Output side: TRX being bought
    'T0000000000000000000000000000000000000001'                                 AS output_contract,  -- TRX native asset
    trx_bought                         AS output_amount

FROM justswap_trx_purchase;


-- SunPump TokenPurchased: User buys tokens with TRX (TRX → Token)
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_sunpump_token_purchased
TO swaps AS
SELECT
    'sunpump' AS protocol,
    -- include everything from sunpump_token_purchased except the non-relevant fields
    * EXCEPT (
        buyer,
        trx_amount,
        token,
        token_amount,
        fee,
        token_reserve
    ),

    -- mapped swap fields
    log_address                        AS pool,
    buyer                              AS user,

    -- Input side: TRX being paid
    'T0000000000000000000000000000000000000001'                                 AS input_contract,  -- TRX native asset
    trx_amount                         AS input_amount,

    -- Output side: Tokens being purchased
    token                              AS output_contract,
    token_amount                       AS output_amount

FROM sunpump_token_purchased;


-- SunPump TokenSold: User sells tokens for TRX (Token → TRX)
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_sunpump_token_sold
TO swaps AS
SELECT
    'sunpump' AS protocol,
    -- include everything from sunpump_token_sold except the non-relevant fields
    * EXCEPT (
        seller,
        token,
        token_amount,
        trx_amount,
        fee
    ),

    -- mapped swap fields
    log_address                        AS pool,
    seller                             AS user,

    -- Input side: Tokens being sold
    token                              AS input_contract,
    token_amount                       AS input_amount,

    -- Output side: TRX being received
    'T0000000000000000000000000000000000000001'                                 AS output_contract,  -- TRX native asset
    trx_amount                         AS output_amount

FROM sunpump_token_sold;