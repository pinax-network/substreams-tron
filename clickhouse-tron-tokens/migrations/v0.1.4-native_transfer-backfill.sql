INSERT INTO native_transfer_minutes
SELECT
    `from`,
    `to`,
    toStartOfMinute(timestamp) AS minute
FROM native_transfer
WHERE year(timestamp) < 2023;