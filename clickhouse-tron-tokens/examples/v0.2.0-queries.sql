-- count() --
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

-- minute filter + transfers --
EXPLAIN indexes =1, projections =1
WITH minutes AS (
    SELECT minute
    FROM trc20_transfer
    WHERE log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'
     AND `from` = 'TYASr5UV6HEcXatwdFQfmLVUqQQQMUxHLS'
    GROUP BY minute
)
SELECT * FROM trc20_transfer
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
WHERE log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'
 AND `from` = 'TN12qS4gM6qs3B2R4XjuT2zf6BomaDGdRY'
GROUP BY minute

-- 3x filters --
EXPLAIN indexes =1, projections =1
SELECT minute
FROM trc20_transfer
WHERE log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'
 AND `from` = 'TN12qS4gM6qs3B2R4XjuT2zf6BomaDGdRY'
 AND `to` = 'TT7wzwKZAdQNhqsyFjTDa3TkGxL7nU6EbD'
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