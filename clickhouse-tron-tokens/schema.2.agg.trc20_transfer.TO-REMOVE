-- OHLCV prices --
CREATE TABLE IF NOT EXISTS trc20_transfer_agg (
    -- intervals --
    timestamp               DateTime('UTC', 0) COMMENT 'beginning of the bar',
    interval_min            UInt16 COMMENT 'bar interval in minutes (1d, 1w)',

    -- order keys --
    log_address             LowCardinality(String),
    account                 String,

    -- last known values --
    last_block_num          SimpleAggregateFunction(max, UInt32),
    last_timestamp          SimpleAggregateFunction(max, DateTime('UTC', 0)),

    -- transfers --
    transfer_in             SimpleAggregateFunction(sum, UInt256),
    transfer_out            SimpleAggregateFunction(sum, UInt256),
    transactions            SimpleAggregateFunction(sum, UInt64) COMMENT 'number of transactions in the window',

    -- indexes --
    INDEX idx_timestamp         (timestamp)         TYPE minmax                 GRANULARITY 1,
    INDEX idx_log_address       (log_address)       TYPE bloom_filter           GRANULARITY 1,
    INDEX idx_account           (account)           TYPE bloom_filter           GRANULARITY 1,
    INDEX idx_last_block_num    (last_block_num)    TYPE minmax                 GRANULARITY 1,
    INDEX idx_last_timestamp    (last_timestamp)    TYPE minmax                 GRANULARITY 1,

    -- indexes (volume) --
    INDEX idx_transfer_in       (transfer_in)       TYPE minmax         GRANULARITY 1,
    INDEX idx_transfer_out      (transfer_out)      TYPE minmax         GRANULARITY 1,
    INDEX idx_transactions      (transactions)      TYPE minmax         GRANULARITY 1,
)
ENGINE = AggregatingMergeTree
ORDER BY (
    interval_min,
    log_address, account,
    timestamp
)
COMMENT 'Balances by account and token contract, aggregated by interval';

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_agg_to
TO trc20_transfer_agg
AS
WITH
    -- predefined intervals --
    -- in minutes: 1d, 1w
    [1440, 10080] AS intervals
SELECT
    arrayJoin(intervals) AS interval_min,
    -- floor to the interval in seconds
    toDateTime(intDiv(toUInt32(t.timestamp), interval_min * 60) * interval_min * 60) AS timestamp,

    -- order by keys --
    log_address, `to` as account,

    -- last known values --
    max(t.block_num) AS last_block_num,
    max(t.timestamp) AS last_timestamp,

    -- transfers --
    sum(amount)             AS transfer_in,
    sum(0)                  AS transfer_out,
    count()                 AS transactions
FROM trc20_transfer AS t
GROUP BY
    -- bar interval
    interval_min,
    -- primary keys
    log_address, account,
    -- bar beginning
    timestamp;

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_agg_from
TO trc20_transfer_agg
AS
WITH
    -- predefined intervals --
    -- in minutes: 1d, 1w
    [1440, 10080] AS intervals
SELECT
    arrayJoin(intervals) AS interval_min,
    -- floor to the interval in seconds
    toDateTime(intDiv(toUInt32(t.timestamp), interval_min * 60) * interval_min * 60) AS timestamp,

    -- order by keys --
    log_address, `from` as account,

    -- last known values --
    max(t.block_num) AS last_block_num,
    max(t.timestamp) AS last_timestamp,

    -- transfers --
    sum(0)                  AS transfer_in,
    sum(amount)             AS transfer_out,
    count()                 AS transactions
FROM trc20_transfer AS t
GROUP BY
    -- bar interval
    interval_min,
    -- primary keys
    log_address, account,
    -- bar beginning
    timestamp;