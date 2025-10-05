-- Unified Swaps View --
-- This view combines swap events from JustSwap, SunSwap, and SunPump into a unified format
CREATE TABLE IF NOT EXISTS swaps (
    -- block --
    block_num                   UInt32,
    block_hash                  String,
    timestamp                   DateTime(0, 'UTC'),

    -- transaction --
    tx_index                    UInt32,
    tx_hash                     String,
    tx_from                     String,
    tx_to                       String,
    tx_nonce                    UInt64,
    tx_gas_price                UInt256,
    tx_gas_limit                UInt64,
    tx_gas_used                 UInt64,
    tx_value                    UInt256,

    -- log --
    log_index                   UInt32,
    log_address                 LowCardinality(String),
    log_ordinal                 UInt32,

    -- common swap fields --
    dex                         LowCardinality(String) COMMENT 'DEX protocol (justswap, sunswap, sunpump)',
    pool                        LowCardinality(String) COMMENT 'Pool/exchange contract address',
    user                        String COMMENT 'User wallet address',
    input_contract              LowCardinality(String) COMMENT 'Input token contract address',
    input_amount                UInt256 COMMENT 'Amount of input tokens swapped',
    output_contract             LowCardinality(String) COMMENT 'Output token contract address',
    output_amount               UInt256 COMMENT 'Amount of output tokens received',

    -- indexes --
    INDEX idx_timestamp         (timestamp)         TYPE minmax                 GRANULARITY 1,
    INDEX idx_block_num         (block_num)         TYPE minmax                 GRANULARITY 1,
    INDEX idx_block_hash        (block_hash)        TYPE bloom_filter(0.005)    GRANULARITY 1,
    INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter(0.005)    GRANULARITY 1,
    INDEX idx_dex               (dex)               TYPE set(256)               GRANULARITY 1,
    INDEX idx_pool              (pool)              TYPE bloom_filter(0.005)    GRANULARITY 1,
    INDEX idx_user              (user)              TYPE bloom_filter(0.005)    GRANULARITY 1,
    INDEX idx_input_contract    (input_contract)    TYPE bloom_filter(0.005)    GRANULARITY 1,
    INDEX idx_output_contract   (output_contract)   TYPE bloom_filter(0.005)    GRANULARITY 1,
    INDEX idx_input_amount      (input_amount)      TYPE minmax                 GRANULARITY 1,
    INDEX idx_output_amount     (output_amount)     TYPE minmax                 GRANULARITY 1,
    INDEX idx_contract_pair     (input_contract, output_contract)       TYPE bloom_filter(0.005) GRANULARITY 1,
    INDEX idx_contract_pair_inv (output_contract, input_contract)       TYPE bloom_filter(0.005) GRANULARITY 1
)
ENGINE = ReplacingMergeTree
PARTITION BY toYYYYMM(timestamp)
ORDER BY (
    timestamp, block_num,
    block_hash, tx_index, log_index
)
COMMENT 'Unified swap events from JustSwap, SunSwap, and SunPump';

/* ──────────────────────────────────────────────────────────────────────────
   1. JustSwap → swaps
   ────────────────────────────────────────────────────────────────────────── */
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_justswap_swaps
TO swaps AS
SELECT
    -- block --
    block_num,
    block_hash,
    timestamp,

    -- transaction --
    tx_index,
    tx_hash,
    tx_from,
    tx_to,
    tx_nonce,
    tx_gas_price,
    tx_gas_limit,
    tx_gas_used,
    tx_value,

    -- log --
    log_index,
    log_address,
    log_ordinal,

    -- common fields --
    'justswap'          AS dex,
    pool,
    user,
    input_contract,
    input_amount,
    output_contract,
    output_amount

FROM justswap_swaps
-- ignore dust swaps (typically trying to distort the price)
WHERE input_amount > 1 AND output_amount > 1;

/* ──────────────────────────────────────────────────────────────────────────
   2. SunSwap → swaps
   ────────────────────────────────────────────────────────────────────────── */
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_sunswap_swaps
TO swaps AS
SELECT
    -- block --
    block_num,
    block_hash,
    timestamp,

    -- transaction --
    tx_index,
    tx_hash,
    tx_from,
    tx_to,
    tx_nonce,
    tx_gas_price,
    tx_gas_limit,
    tx_gas_used,
    tx_value,

    -- log --
    log_index,
    log_address,
    log_ordinal,

    -- common fields --
    'sunswap'           AS dex,
    pool,
    sender              AS user,
    input_contract,
    input_amount,
    output_contract,
    output_amount

FROM sunswap_swaps
-- ignore dust swaps (typically trying to distort the price)
WHERE input_amount > 1 AND output_amount > 1;

/* ──────────────────────────────────────────────────────────────────────────
   3. SunPump → swaps
   ────────────────────────────────────────────────────────────────────────── */
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_sunpump_swaps
TO swaps AS
SELECT
    -- block --
    block_num,
    block_hash,
    timestamp,

    -- transaction --
    tx_index,
    tx_hash,
    tx_from,
    tx_to,
    tx_nonce,
    tx_gas_price,
    tx_gas_limit,
    tx_gas_used,
    tx_value,

    -- log --
    log_index,
    log_address,
    log_ordinal,

    -- common fields --
    'sunpump'           AS dex,
    pool,
    user,
    input_contract,
    input_amount,
    output_contract,
    output_amount

FROM sunpump_swaps
-- ignore dust swaps (typically trying to distort the price)
WHERE input_amount > 1 AND output_amount > 1;
