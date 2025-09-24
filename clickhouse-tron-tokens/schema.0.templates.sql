CREATE TABLE IF NOT EXISTS cursor (
    -- block --
    block_num                   UInt32,
    block_hash                  String,
    timestamp                   DateTime(0, 'UTC'),
    cursor                      String,

    -- indexes -
    INDEX idx_timestamp         (timestamp)         TYPE minmax                 GRANULARITY 1,
    INDEX idx_block_num         (block_num)         TYPE minmax                 GRANULARITY 1
)
ENGINE = ReplacingMergeTree
PARTITION BY toYYYYMM(timestamp)
ORDER BY (
    timestamp, block_num,
    block_hash, cursor
);

CREATE TABLE IF NOT EXISTS base_events (
    -- block --
    block_num                   UInt32,
    block_hash                  String,
    timestamp                   DateTime(0, 'UTC'),

    -- transaction --
    transaction_hash            String,
    transaction_from            String,
    transaction_to              String,
    transaction_nonce           UInt64,
    transaction_gas_price       String,
    transaction_gas_limit       UInt64,
    transaction_gas_used        UInt64,
    transaction_value           String,

    -- indexes -
    INDEX idx_timestamp         (timestamp)         TYPE minmax                 GRANULARITY 1,
    INDEX idx_block_num         (block_num)         TYPE minmax                 GRANULARITY 1,
    INDEX idx_transaction_hash  (transaction_hash)  TYPE bloom_filter(0.005)    GRANULARITY 1,
    INDEX idx_transaction_from  (transaction_from)  TYPE bloom_filter(0.005)    GRANULARITY 1,
    INDEX idx_transaction_to    (transaction_to)    TYPE bloom_filter(0.005)    GRANULARITY 1
)
ENGINE = ReplacingMergeTree
PARTITION BY toYYYYMM(timestamp)
ORDER BY (
    timestamp, block_num,
    block_hash, transaction_hash
);