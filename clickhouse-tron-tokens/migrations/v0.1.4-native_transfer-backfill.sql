INSERT INTO native_transfer_minutes
SELECT DISTINCT
    `from`,
    `to`,
    toStartOfMinute(timestamp) AS minute
FROM native_transfer
WHERE year(timestamp) = 2022;

/* Backfill for 2018-2025 */