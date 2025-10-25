-- OHLC Prices by Pool --
WITH (
      pow(10, 6) AS scale0,
      pow(10, 6) AS scale1,
      pow(10, 6 - 6) AS scale,
      6 AS precision -- user defined
) SELECT
      timestamp,
      'TRX/USDT' AS ticker,

      -- OHLC --
      floor(argMinMerge(open0) * scale, precision)                        AS open,
      floor(quantileDeterministicMerge(0.99)(quantile0) * scale, precision)   AS high,
      floor(quantileDeterministicMerge(0.01)(quantile0) * scale, precision)    AS low,
      floor(argMaxMerge(close0) * scale, precision)                       AS close,

      -- volume --
      floor(sum(gross_volume0) / scale0, precision)         AS "gross volume (TRX)",
      floor(sum(gross_volume1) / scale1, precision)         AS "gross volume (USDT)",
      floor(sum(net_flow0) / scale0, precision)             AS "net flow (TRX)",
      floor(sum(net_flow1) / scale1, precision)             AS "net flow (USDT)",

      -- universal --
      uniqMerge(uaw)          AS uaw,
      sum(transactions)       AS transactions
FROM ohlc_prices
WHERE interval_min = 60 AND pool = 'TFGDbUyP8xez44C76fin3bn3Ss6jugoUwJ' -- SUNSWAP-USDT-TRX V2 (S-USDT-TRX)
GROUP BY pool, timestamp
ORDER BY timestamp DESC
LIMIT 10;