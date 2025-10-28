-- OHLCV prices --
CREATE TABLE IF NOT EXISTS ohlc_prices (
    timestamp               DateTime('UTC', 0) COMMENT 'beginning of the bar',
    interval_min            UInt16 DEFAULT 1 COMMENT 'bar interval in minutes (1min,1hr,1day)',

    -- chain + DEX identity
    protocol                LowCardinality(String),
    factory                 LowCardinality(String),
    pool                    LowCardinality(String),

    -- token identity (normalized ids as strings)
    token0                  LowCardinality(String),
    token1                  LowCardinality(String),

    -- Aggregate --
    open0                   AggregateFunction(argMin, Float64, UInt64),
    quantile0               AggregateFunction(quantileDeterministic, Float64, UInt64),
    close0                  AggregateFunction(argMax, Float64, UInt64),

    -- volume --
    gross_volume0           SimpleAggregateFunction(sum, Int256) COMMENT 'gross volume of token0 in the window',
    gross_volume1           SimpleAggregateFunction(sum, Int256) COMMENT 'gross volume of token1 in the window',
    net_flow0               SimpleAggregateFunction(sum, Int256) COMMENT 'net flow of token0 in the window',
    net_flow1               SimpleAggregateFunction(sum, Int256) COMMENT 'net flow of token1 in the window',

    -- universal --
    uaw                     AggregateFunction(uniq, String) COMMENT 'unique wallet addresses in the window',
    transactions            SimpleAggregateFunction(sum, UInt64) COMMENT 'number of transactions in the window',

    -- indexes --
    INDEX idx_timestamp         (timestamp)         TYPE minmax                 GRANULARITY 1,
    INDEX idx_protocol          (protocol)          TYPE set(4)                 GRANULARITY 1,
    INDEX idx_factory           (factory)           TYPE set(1024)              GRANULARITY 1,
    INDEX idx_pool              (pool)              TYPE bloom_filter           GRANULARITY 1,
    INDEX idx_token0            (token0)            TYPE bloom_filter           GRANULARITY 1,
    INDEX idx_token1            (token1)            TYPE bloom_filter           GRANULARITY 1,
    INDEX idx_token_pair        (token0, token1)    TYPE bloom_filter           GRANULARITY 1,
    INDEX idx_token_pair_inv    (token1, token0)    TYPE bloom_filter           GRANULARITY 1,

    -- indexes (volume) --
    INDEX idx_gross_volume0     (gross_volume0)     TYPE minmax         GRANULARITY 1,
    INDEX idx_gross_volume1     (gross_volume1)     TYPE minmax         GRANULARITY 1,
    INDEX idx_net_flow0         (net_flow0)         TYPE minmax         GRANULARITY 1,
    INDEX idx_net_flow1         (net_flow1)         TYPE minmax         GRANULARITY 1,
    INDEX idx_transactions      (transactions)      TYPE minmax         GRANULARITY 1
)
ENGINE = AggregatingMergeTree
ORDER BY (
    interval_min,
    pool, factory, protocol, token0, token1,
    timestamp
)
COMMENT 'OHLCV prices for AMM pools, aggregated by interval';

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_ohlc_prices
TO ohlc_prices
AS
WITH
    -- predefined intervals --
    -- in minutes: 1m, 5m, 10m, 30m, 1h, 4h, 1d, 1w
    [1, 5, 10, 30, 60, 240, 1440, 10080] AS intervals,

    -- canonical token ordering
    (input_contract <= output_contract) AS dir,
    if (dir, input_contract,  output_contract) AS token0,
    if (dir, output_contract, input_contract) AS token1,
    if (dir, input_amount,  output_amount) AS amount0,
    if (dir, output_amount, input_amount) AS amount1,
    toFloat64(amount1) / amount0 AS price,
    abs(amount0) AS gv0,
    abs(amount1) AS gv1,
    -- net flow of mint0: +in, -out
    if(dir, toInt256(input_amount), -toInt256(output_amount))  AS nf0,
    -- net flow of mint1: +in, -out (signs flipped vs. your original)
    if(dir, -toInt256(output_amount), toInt256(input_amount))  AS nf1

SELECT
    arrayJoin(intervals) AS interval_min,
    -- floor to the interval in seconds
    toDateTime(intDiv(toUInt32(s.timestamp), interval_min * 60) * interval_min * 60) AS timestamp,

    -- toStartOfMinute(s.timestamp) AS timestamp,
    protocol, factory, pool, token0, token1,

    /* OHLC */
    argMinState(price, toUInt64(block_num))                 AS open0,
    quantileDeterministicState(price, toUInt64(block_num))  AS quantile0,
    argMaxState(price, toUInt64(block_num))                 AS close0,

    /* volumes & flows (all in canonical orientation) */
    sum(gv0)                AS gross_volume0,
    sum(gv1)                AS gross_volume1,
    sum(nf0)                AS net_flow0,
    sum(nf1)                AS net_flow1,

    /* universal */
    uniqState(user)         AS uaw,
    count()                 AS transactions
FROM swaps s
GROUP BY
    -- bar interval
    interval_min,
    -- canonical token ordering
    pool, factory, protocol, token0, token1,
     -- bar beginning
    timestamp;