CREATE TABLE IF NOT EXISTS TEMPLATE_LOG (
    -- block --
    block_num                   UInt32,
    block_hash                  String,
    timestamp                   DateTime(0, 'UTC'),

    -- transaction --
    tx_index                    UInt32, -- derived from Substreams
    tx_hash                     String,
    tx_from                     String,
    tx_to                       String,
    tx_nonce                    UInt64,
    tx_gas_price                UInt256,
    tx_gas_limit                UInt64,
    tx_gas_used                 UInt64,
    tx_value                    UInt256,

    -- log --
    log_index                   UInt32, -- derived from Substreams
    log_address                 String,
    log_ordinal                 UInt32,
    -- log_topic0                  String, -- only available in tron-tokens-v0.1.1

    -- indexes --
    INDEX idx_block_num         (block_num)         TYPE minmax                 GRANULARITY 1,
    INDEX idx_block_hash        (block_hash)        TYPE bloom_filter           GRANULARITY 1,
    INDEX idx_tx_hash           (tx_hash)           TYPE bloom_filter           GRANULARITY 1,
    INDEX idx_tx_from           (tx_from)           TYPE bloom_filter           GRANULARITY 1,
    INDEX idx_tx_to             (tx_to)             TYPE bloom_filter           GRANULARITY 1,
    INDEX idx_tx_value          (tx_value)          TYPE minmax                 GRANULARITY 1,
    INDEX idx_tx_nonce          (tx_nonce)          TYPE minmax                 GRANULARITY 1,
    INDEX idx_tx_gas_price      (tx_gas_price)      TYPE minmax                 GRANULARITY 1,
    INDEX idx_tx_gas_limit      (tx_gas_limit)      TYPE minmax                 GRANULARITY 1,
    INDEX idx_tx_gas_used       (tx_gas_used)       TYPE minmax                 GRANULARITY 1,

    -- indexes (ordering) --
    INDEX idx_tx_index          (tx_index)          TYPE minmax                 GRANULARITY 1,
    INDEX idx_log_index         (log_index)         TYPE minmax                 GRANULARITY 1,

    -- indexes (log) --
    INDEX idx_log_address       (log_address)           TYPE bloom_filter           GRANULARITY 1,
    INDEX idx_log_ordinal       (log_ordinal)           TYPE minmax                 GRANULARITY 1,
    -- INDEX idx_log_topic0        (log_topic0)            TYPE bloom_filter           GRANULARITY 1, -- only available in tron-tokens-v0.1.1

)
ENGINE = ReplacingMergeTree
ORDER BY (
    timestamp, block_num,
    block_hash, tx_index, log_index
);

-- Settings and projections --
ALTER TABLE TEMPLATE_LOG
    MODIFY SETTING deduplicate_merge_projection_mode = 'rebuild';
ALTER TABLE TEMPLATE_LOG
    -- projections --
    ADD PROJECTION IF NOT EXISTS prj_tx_hash                               (SELECT tx_hash, toRelativeMinuteNum(timestamp) AS minute GROUP BY tx_hash, minute),
    ADD PROJECTION IF NOT EXISTS prj_tx_hash_offset                        (SELECT tx_hash, _part_offset ORDER BY (tx_hash)),

    -- projections (filters by minute) --
    ADD PROJECTION IF NOT EXISTS prj_tx_from_by_relative_minute            (SELECT tx_from, toRelativeMinuteNum(timestamp) AS minute GROUP BY tx_from, minute),
    ADD PROJECTION IF NOT EXISTS prj_tx_to_by_relative_minute              (SELECT tx_to, toRelativeMinuteNum(timestamp) AS minute GROUP BY tx_to, minute),
    ADD PROJECTION IF NOT EXISTS prj_log_address_by_relative_minute        (SELECT log_address, toRelativeMinuteNum(timestamp) AS minute GROUP BY log_address, minute);

-- Template for Transactions (without log fields) --
CREATE TABLE IF NOT EXISTS TEMPLATE_TRANSACTION AS TEMPLATE_LOG
ORDER BY (
    timestamp, block_num,
    block_hash, tx_index
);
ALTER TABLE TEMPLATE_TRANSACTION
    DROP PROJECTION IF EXISTS prj_log_address_by_relative_minute,
    DROP INDEX IF EXISTS idx_log_index,
    DROP INDEX IF EXISTS idx_log_address,
    DROP INDEX IF EXISTS idx_log_ordinal,
    -- DROP INDEX IF EXISTS idx_log_topic0, // only available in tron-tokens-v0.1.1
    DROP COLUMN IF EXISTS log_index,
    DROP COLUMN IF EXISTS log_address,
    DROP COLUMN IF EXISTS log_ordinal,
    DROP COLUMN IF EXISTS log_topic0;