CREATE TABLE IF NOT EXISTS TEMPLATE_LOG (
    -- block --
    block_num                   UInt32,
    block_hash                  String,
    timestamp                   DateTime('UTC'),

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

    -- projections --
    PROJECTION prj_block_hash_by_timestamp ( SELECT block_hash, timestamp, count() GROUP BY block_hash, timestamp ),
    PROJECTION prj_tx_hash_by_timestamp ( SELECT tx_hash, timestamp, count() GROUP BY tx_hash, timestamp ),
    PROJECTION prj_log_address_by_minute ( SELECT log_address, minute, count() GROUP BY log_address, minute )
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
