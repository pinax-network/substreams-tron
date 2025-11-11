CREATE TABLE IF NOT EXISTS TEMPLATE_LOG (
    -- block --
    block_num                   UInt32,
    block_hash                  String,
    timestamp                   DateTime('UTC'),

    -- derived time fields --
    minute                      UInt32 COMMENT 'toRelativeMinuteNum(timestamp)',

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
    log_topic0                  String, -- only available in tron-tokens-v0.1.1

    -- INDEXES --
    INDEX idx_tx_value (tx_value) TYPE minmax GRANULARITY 1,
    INDEX idx_log_ordinal (log_ordinal) TYPE minmax GRANULARITY 1,

    -- PROJECTIONS --
    -- count() --
    PROJECTION prj_tx_from_count ( SELECT tx_from, count() GROUP BY tx_from ),
    PROJECTION prj_tx_to_count ( SELECT tx_to, count() GROUP BY tx_to ),
    PROJECTION prj_tx_to_from_count ( SELECT tx_to, tx_from, count() GROUP BY tx_to, tx_from ),
    PROJECTION prj_log_topic0_count ( SELECT log_topic0, count() GROUP BY log_topic0 ),
    PROJECTION prj_log_address_count ( SELECT log_address, count() GROUP BY log_address ),

    -- minute --
    PROJECTION prj_block_hash_by_timestamp ( SELECT block_hash, minute, timestamp, count() GROUP BY block_hash, minute,timestamp ),
    PROJECTION prj_tx_hash_by_timestamp ( SELECT tx_hash, minute, timestamp, count() GROUP BY tx_hash, minute, timestamp ),
    PROJECTION prj_log_address_by_minute ( SELECT log_address, minute, count() GROUP BY log_address, minute )
)
ENGINE = MergeTree
ORDER BY (
    minute, timestamp, block_num,
    tx_index, log_index
);

-- Template for Transactions (without log fields) --
CREATE TABLE IF NOT EXISTS TEMPLATE_TRANSACTION AS TEMPLATE_LOG
ENGINE = MergeTree
ORDER BY (
    minute, timestamp, block_num,
    tx_index
);
ALTER TABLE TEMPLATE_TRANSACTION
    DROP PROJECTION IF EXISTS prj_log_address_by_minute,
    DROP PROJECTION IF EXISTS prj_log_topic0_count,
    DROP PROJECTION IF EXISTS prj_log_address_count,
    DROP INDEX IF EXISTS idx_log_ordinal,
    DROP COLUMN IF EXISTS log_index,
    DROP COLUMN IF EXISTS log_address,
    DROP COLUMN IF EXISTS log_ordinal,
    DROP COLUMN IF EXISTS log_topic0;
