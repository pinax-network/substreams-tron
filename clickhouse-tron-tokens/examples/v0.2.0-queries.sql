-- count() TRC-20 --
EXPLAIN indexes =1, projections =1
SELECT
    log_address,
    `from`,
    `to`,
    count()
FROM trc20_transfer
GROUP BY log_address, `from`, `to`
ORDER BY count() DESC
LIMIT 10

-- count() Native --
EXPLAIN indexes =1, projections =1
SELECT
    `from`,
    count()
FROM native_transfer
GROUP BY `from`
ORDER BY count() DESC
LIMIT 10

-- minute Native --
EXPLAIN indexes =1, projections =1
SELECT minute
FROM native_transfer
WHERE `from` = 'TAUN6FwrnwwmaEqYcckffC7wYmbaS6cBiX'
GROUP BY minute

EXPLAIN indexes =1, projections =1
SELECT minute
FROM native_transfer
WHERE `to` = 'TKpn4QSQ6Q1fKkF67Ljz2qmnskrLXGi9tP'
GROUP BY minute

-- minute filter + TRC-20 transfers --
EXPLAIN indexes =1, projections =1
WITH minutes AS (
    SELECT minute
    FROM trc20_transfer
    WHERE log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'
    GROUP BY minute
    ORDER BY minute DESC
    LIMIT 100000
)
SELECT *, floor(minute / 60) AS hour FROM trc20_transfer
WHERE minute in minutes
LIMIT 10

-- minute filter + Native transfers --
EXPLAIN indexes =1, projections =1
WITH minutes AS (
    SELECT minute
    FROM native_transfer
    WHERE `from` = 'TU6UZuR8Z1adXK2e4TocXUg7YqyeWJiJLE'
    GROUP BY minute

    INTERSECT ALL

    SELECT minute
    FROM native_transfer
    WHERE `to` = 'TCFNp179Lg46D16zKoumd4Poa2WFFdtqYj'
    GROUP BY minute
)
SELECT * FROM native_transfer
WHERE minute IN minutes
LIMIT 10

-- 1x filters --
EXPLAIN indexes =1, projections =1
SELECT minute
FROM trc20_transfer
WHERE log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'
GROUP BY minute

-- 2x filters --
EXPLAIN indexes =1, projections =1
SELECT minute
FROM trc20_transfer
WHERE `from` = 'TN12qS4gM6qs3B2R4XjuT2zf6BomaDGdRY'
GROUP BY minute

INTERSECT ALL

SELECT minute
FROM trc20_transfer
WHERE log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'
GROUP BY minute

-- 3x filters --
EXPLAIN indexes =1, projections =1
SELECT minute
FROM trc20_transfer
WHERE `from` = 'TN12qS4gM6qs3B2R4XjuT2zf6BomaDGdRY'
GROUP BY minute

INTERSECT ALL

SELECT minute
FROM trc20_transfer
WHERE`to` = 'TT7wzwKZAdQNhqsyFjTDa3TkGxL7nU6EbD'
GROUP BY minute

INTERSECT ALL

SELECT minute
FROM trc20_transfer
WHERE log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'
GROUP BY minute

-- count() --
EXPLAIN indexes =1, projections =1
SELECT
    log_address,
    dst,
    count()
FROM weth_deposit
GROUP BY log_address, dst
ORDER BY count() DESC
LIMIT 10

-- minute filter + transfers --
EXPLAIN indexes =1, projections =1
WITH minutes AS (
    SELECT minute
    FROM weth_deposit
    WHERE dst = 'TXF1xDbVGdxFGbovmmmXvBGu8ZiE3Lq4mR'
    GROUP BY minute
)
SELECT * FROM weth_deposit
WHERE minute IN minutes
LIMIT 10

-- -- multiple filters + tx_hash filter --
-- EXPLAIN indexes = 1, projections =1
-- WITH tx_hash_timestamps AS (
--     SELECT (minute, timestamp)
--     FROM trc20_transfer
--     WHERE `tx_hash` = '4d304d14a55d46e64d7397d3a2f1871dbd5d781d000aed0b40ead718ee6cf718'
--     GROUP BY (minute, timestamp)
-- )
-- SELECT * FROM trc20_transfer
-- WHERE (minute, timestamp) IN tx_hash_timestamps
--     AND log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'
--     AND `from` = 'TGeTuAn9ASi3tgTaXaQX1WFAinrQgwPHLE'
--     AND `to` = 'TEsAm2sepCHsVLsMe4Fi6zhHX9AbsTQZ5G'
--     AND `tx_hash` = '4d304d14a55d46e64d7397d3a2f1871dbd5d781d000aed0b40ead718ee6cf718'
-- LIMIT 10