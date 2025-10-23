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

    -- indexes --
    INDEX idx_timestamp         (timestamp)         TYPE minmax                 GRANULARITY 1,
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
    INDEX idx_log_ordinal       (log_ordinal)           TYPE minmax                 GRANULARITY 1
)
ENGINE = ReplacingMergeTree
ORDER BY (
    timestamp, block_num,
    block_hash, tx_index, log_index
);

ALTER TABLE TEMPLATE_LOG
  MODIFY SETTING deduplicate_merge_projection_mode = 'rebuild';

ALTER TABLE TEMPLATE_LOG
    ADD PROJECTION IF NOT EXISTS prj_tx_hash (SELECT tx_hash, timestamp, _part_offset ORDER BY (tx_hash, timestamp)),
    ADD PROJECTION IF NOT EXISTS prj_tx_from (SELECT tx_from, timestamp, _part_offset ORDER BY (tx_from, timestamp)),
    ADD PROJECTION IF NOT EXISTS prj_tx_to (SELECT tx_to, timestamp, _part_offset ORDER BY (tx_to, timestamp)),
    ADD PROJECTION IF NOT EXISTS prj_log_address (SELECT log_address, timestamp, _part_offset ORDER BY (log_address, timestamp));
