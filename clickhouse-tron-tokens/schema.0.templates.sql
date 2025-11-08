CREATE TABLE IF NOT EXISTS TEMPLATE_LOG (
    -- block --
    block_num                   UInt32,
    block_hash                  String,
    timestamp                   DateTime(0, 'UTC'),

    -- derived time fields --
    minute                     DateTime('UTC') MATERIALIZED toStartOfMinute(timestamp),
    hour                       DateTime('UTC') MATERIALIZED toStartOfHour(timestamp),
    date                       Date MATERIALIZED toDate(timestamp),

    -- transaction --
    tx_index                    UInt32, -- derived from Substreams
    tx_hash                     String,
    tx_from                     String,
    tx_to                       LowCardinality(String),
    tx_nonce                    UInt64,
    tx_gas_price                UInt256,
    tx_gas_limit                UInt64,
    tx_gas_used                 UInt64,
    tx_value                    UInt256,

    -- log --
    log_index                   UInt32, -- derived from Substreams
    log_address                 LowCardinality(String),
    log_ordinal                 UInt32,
    -- log_topic0                  String, -- only available in tron-tokens-v0.1.1

    -- indexes --
    INDEX idx_block_num         (block_num)             TYPE minmax                 GRANULARITY 1,
    INDEX idx_timestamp         (timestamp)             TYPE minmax                 GRANULARITY 1,
    INDEX idx_minute            (minute)                TYPE minmax                 GRANULARITY 1,
    INDEX idx_hour              (hour)                  TYPE minmax                 GRANULARITY 1,
    INDEX idx_date              (date)                  TYPE minmax                 GRANULARITY 1,

    -- indexes (transaction) --
    INDEX idx_tx_value          (tx_value)              TYPE minmax                 GRANULARITY 1,
    INDEX idx_tx_nonce          (tx_nonce)              TYPE minmax                 GRANULARITY 1,
    INDEX idx_tx_gas_price      (tx_gas_price)          TYPE minmax                 GRANULARITY 1,
    INDEX idx_tx_gas_limit      (tx_gas_limit)          TYPE minmax                 GRANULARITY 1,
    INDEX idx_tx_gas_used       (tx_gas_used)           TYPE minmax                 GRANULARITY 1,

    -- indexes (ordering) --
    INDEX idx_tx_index          (tx_index)              TYPE minmax                 GRANULARITY 1,
    INDEX idx_log_index         (log_index)             TYPE minmax                 GRANULARITY 1,

    -- indexes (log) --
    INDEX idx_log_ordinal       (log_ordinal)           TYPE minmax                 GRANULARITY 1,

    -- projections by timestamp --
    -- helpful for filtering by time ranges --
    -- tx_hash/block_hash --
    PROJECTION prj_tx_hash_by_timestamp ( SELECT tx_hash, timestamp, count() GROUP BY tx_hash, timestamp ),
    PROJECTION prj_block_hash_by_timestamp ( SELECT block_hash, timestamp, count() GROUP BY block_hash, timestamp ),

    -- tx_from/to --
    PROJECTION prj_tx_from_by_minute ( SELECT tx_from, date, hour, minute, count() GROUP BY tx_from, date, hour, minute ),
    PROJECTION prj_tx_to_by_minute ( SELECT tx_to, date, hour, minute, count() GROUP BY tx_to, date, hour, minute ),

    -- tx_from + tx_to --
    PROJECTION prj_tx_from_to_by_minute ( SELECT tx_from, tx_to, date, hour, minute, count() GROUP BY tx_from, tx_to, date, hour, minute ),
    PROJECTION prj_tx_to_from_by_minute ( SELECT tx_to, tx_from, date, hour, minute, count() GROUP BY tx_to, tx_from, date, hour, minute ),

    -- log_address --
    PROJECTION prj_log_address_by_minute ( SELECT log_address, date, hour, minute, count() GROUP BY log_address, date, hour, minute )
)
ENGINE = MergeTree
ORDER BY (
    timestamp, block_num, tx_index, log_index
);

-- Template for Transactions (without log fields) --
CREATE TABLE IF NOT EXISTS TEMPLATE_TRANSACTION AS TEMPLATE_LOG
ENGINE = MergeTree
ORDER BY (
    timestamp, block_num, tx_index
);
ALTER TABLE TEMPLATE_TRANSACTION
    DROP PROJECTION IF EXISTS prj_log_address_by_minute,
    DROP INDEX IF EXISTS idx_log_index,
    DROP INDEX IF EXISTS idx_log_address,
    DROP INDEX IF EXISTS idx_log_ordinal,
    -- DROP INDEX IF EXISTS idx_log_topic0, // only available in tron-tokens-v0.1.1
    DROP COLUMN IF EXISTS log_index,
    DROP COLUMN IF EXISTS log_address,
    DROP COLUMN IF EXISTS log_ordinal,
    DROP COLUMN IF EXISTS log_topic0;
