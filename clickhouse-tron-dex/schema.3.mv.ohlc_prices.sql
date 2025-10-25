-- OHLCV prices --
CREATE TABLE IF NOT EXISTS ohlc_prices (
    timestamp               DateTime('UTC', 0) COMMENT 'beginning of the bar',

    -- OrderBy --
    factory                 LowCardinality(String),
    pool                    LowCardinality(String),
    contract0               LowCardinality(String),
    contract1               LowCardinality(String),

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
    INDEX idx_factory           (factory)           TYPE set(256)               GRANULARITY 1,
    INDEX idx_pool              (pool)              TYPE bloom_filter           GRANULARITY 1,
    INDEX idx_contract0         (contract0)         TYPE bloom_filter           GRANULARITY 1,
    INDEX idx_contract1         (contract1)         TYPE bloom_filter           GRANULARITY 1,
    INDEX idx_contract_pair     (contract0, contract1)      TYPE bloom_filter           GRANULARITY 1,

    -- indexes (volume) --
    INDEX idx_gross_volume0     (gross_volume0)     TYPE minmax         GRANULARITY 1,
    INDEX idx_gross_volume1     (gross_volume1)     TYPE minmax         GRANULARITY 1,
    INDEX idx_net_flow0         (net_flow0)         TYPE minmax         GRANULARITY 1,
    INDEX idx_net_flow1         (net_flow1)         TYPE minmax         GRANULARITY 1,
    INDEX idx_transactions      (transactions)      TYPE minmax         GRANULARITY 1,
)
ENGINE = AggregatingMergeTree
ORDER BY (timestamp, factory, pool, contract0, contract1)
COMMENT 'OHLCV prices for DEX pools, aggregated by minute';

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_ohlc_prices
TO ohlc_prices
AS
WITH
    (input_contract <= output_contract) AS dir,
    if (dir, input_contract,  output_contract) AS contract0,
    if (dir, output_contract, input_contract) AS contract1,
    if (dir, input_amount,  output_amount) AS amount0,
    if (dir, output_amount, input_amount) AS amount1,
    toFloat64(amount1) / amount0 AS price,
    abs(amount0) AS gv0,
    abs(amount1) AS gv1,
    -- net flow of mint0: +in, -out
    if(dir, toInt128(input_amount), -toInt128(output_amount))  AS nf0,
    -- net flow of mint1: +in, -out (signs flipped vs. your original)
    if(dir, -toInt128(output_amount), toInt128(input_amount))  AS nf1

SELECT
    toStartOfMinute(s.timestamp)    AS timestamp,
    factory, pool, contract0, contract1,

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
GROUP BY timestamp, factory, pool, contract0, contract1;
