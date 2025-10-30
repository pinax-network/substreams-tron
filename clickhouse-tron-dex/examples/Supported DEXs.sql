-- Supported DEXs --
WITH all_dexes AS (
    SELECT
        protocol,
        factory,
        sum(transactions) as transactions,
        uniqMerge(uaw) as uaw,
        max(timestamp) as last_activity
    FROM ohlc_prices
    WHERE interval_min = 1440
    GROUP BY
        protocol,
        factory
)
SELECT * FROM all_dexes
ORDER BY transactions DESC
LIMIT 20;

-- Supported DEXs by Pools --
WITH all_dexes AS (
    SELECT
        protocol,
        factory,
        pool,
        sum(transactions) as transactions,
        uniqMerge(uaw) as uaw,
        max(timestamp) as last_activity
    FROM ohlc_prices
    WHERE interval_min = 1440
    GROUP BY
        protocol,
        factory,
        pool
)
SELECT * FROM all_dexes
ORDER BY transactions DESC
LIMIT 20

-- TEST with swaps --
SELECT
    protocol,
    factory,
    count() as transactions,
    uniq(user) as uaw,
    max(timestamp) as last_activity
FROM swaps
GROUP BY
    protocol,
    factory
ORDER BY transactions DESC
LIMIT 20;