-- by tx hash

EXPLAIN indexes = 1, projections = 1
WITH timestamps AS (
    SELECT timestamp
    FROM trc20_transfer
    WHERE tx_hash ='46c608cd66c873753f7d86a3dc6b46453052505730cc5f6e951533083b1d40ab'
    GROUP BY timestamp
)
SELECT * FROM trc20_transfer
WHERE timestamp IN timestamps
      AND tx_hash ='46c608cd66c873753f7d86a3dc6b46453052505730cc5f6e951533083b1d40ab'
ORDER BY timestamp DESC
LIMIT 10;



-- single filter ✅
EXPLAIN indexes = 1, projections = 1
WITH minutes AS (
    SELECT minute
    FROM trc20_transfer_minutes
    WHERE `from` = 'TAYtGZzxZf1GhPfGwZKskWQnz7Qj3rwLDh'
    GROUP BY minute
)
SELECT * FROM trc20_transfer
WHERE minute IN minutes
ORDER BY timestamp DESC
LIMIT 10;

-- single filter ✅ v0.1.2
EXPLAIN indexes = 1, projections = 1
WITH minutes AS (
    SELECT toRelativeMinuteNum(timestamp) AS minute
    FROM trc20_transfer
    WHERE `from` = 'TAYtGZzxZf1GhPfGwZKskWQnz7Qj3rwLDh'
    GROUP BY minute
)
SELECT * FROM trc20_transfer
WHERE minute IN minutes
ORDER BY timestamp DESC
LIMIT 10;

-- double filter + token metadata ✅ 0.8s
EXPLAIN PIPELINE
WITH
minutes AS (
    SELECT minute
    FROM trc20_transfer_minutes
    WHERE log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t' AND `from` = 'TAYtGZzxZf1GhPfGwZKskWQnz7Qj3rwLDh'
    GROUP BY minute
    ORDER BY minute DESC
),
transfers AS (
    SELECT *
    FROM trc20_transfer
    WHERE toStartOfMinute(timestamp) IN minutes
    ORDER BY timestamp DESC, block_num DESC, tx_index DESC, log_index DESC
    LIMIT 10
    OFFSET 0
),
distinct_contracts AS (
    SELECT DISTINCT log_address AS contract
    FROM transfers
),
metadata AS (
    SELECT DISTINCT
        contract,
        name,
        symbol,
        decimals
    FROM `tron:tvm-tokens@v0.1.2`.metadata
    WHERE contract IN distinct_contracts
)
SELECT * FROM transfers t
LEFT JOIN metadata m ON t.log_address = m.contract
ORDER BY t.timestamp DESC;

-- double filter ✅
EXPLAIN indexes = 1, projections = 1
WITH from_minutes AS (
    SELECT minute
    FROM trc20_transfer_minutes
    WHERE `from` = 'TAYtGZzxZf1GhPfGwZKskWQnz7Qj3rwLDh'
    GROUP BY minute
), log_address_minutes AS (
    SELECT minute
    FROM trc20_transfer_minutes
    WHERE log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'
    GROUP BY minute
), minutes AS (
    SELECT minute
    FROM from_minutes
    INTERSECT
    SELECT minute
    FROM log_address_minutes
)
SELECT * FROM trc20_transfer
WHERE toStartOfMinute(timestamp) IN minutes
ORDER BY timestamp DESC
LIMIT 10;

-- single filter (10 minutes) ❌
EXPLAIN indexes = 1, projections = 1
WITH minutes AS (
    SELECT toStartOfTenMinutes(minute) AS t
    FROM trc20_transfer_minutes
    WHERE `from` = 'TAYtGZzxZf1GhPfGwZKskWQnz7Qj3rwLDh'
    GROUP BY t
)
SELECT * FROM trc20_transfer
WHERE toStartOfTenMinutes(timestamp) IN minutes
ORDER BY timestamp DESC
LIMIT 10;

-- single filter (log_address) ✅ 0.12s
EXPLAIN indexes = 1, projections = 1
WITH minutes AS (
    SELECT minute
    FROM trc20_transfer_minutes
    WHERE log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'
    GROUP BY minute
    ORDER BY minute DESC
    LIMIT 10000
)
SELECT * FROM trc20_transfer
WHERE toStartOfMinute(timestamp) IN minutes
ORDER BY timestamp DESC
LIMIT 10;

-- single filter (10 minutes) ⚠️ no change
EXPLAIN indexes = 1, projections = 1
WITH ten_minutes AS (
    SELECT toStartOfTenMinutes(minute) AS t
    FROM trc20_transfer_minutes
    WHERE log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'
    GROUP BY t
    ORDER BY t DESC
    LIMIT 1000
)
SELECT * FROM trc20_transfer
WHERE toStartOfTenMinutes(timestamp) IN ten_minutes
ORDER BY timestamp DESC
LIMIT 10;

-- single filter (1 hour) ⚠️ no change
EXPLAIN indexes = 1, projections = 1
WITH hours AS (
    SELECT toStartOfHour(minute) AS t
    FROM trc20_transfer_minutes
    WHERE log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'
    GROUP BY t
    ORDER BY t DESC
    LIMIT 1000
)
SELECT * FROM trc20_transfer
WHERE toStartOfHour(timestamp) IN hours
ORDER BY timestamp DESC
LIMIT 10;


-- single filter (log_address) ✅ 0.12s
EXPLAIN indexes = 1, projections = 1
WITH minutes AS (
    SELECT minute
    FROM trc20_transfer_minutes
    WHERE
        `from` = 'TAYtGZzxZf1GhPfGwZKskWQnz7Qj3rwLDh' AND
        `to` = 'THWuviP5wEiPBLZ1g1iPPiH4kV7FRXWFP1' AND
        log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'
    GROUP BY minute
    ORDER BY minute DESC
    LIMIT 10000
)
SELECT * FROM trc20_transfer
WHERE toStartOfMinute(timestamp) IN minutes
ORDER BY timestamp DESC
LIMIT 10;