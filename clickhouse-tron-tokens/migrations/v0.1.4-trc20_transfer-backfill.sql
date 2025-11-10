INSERT INTO trc20_transfer_minutes
SELECT DISTINCT
    log_address,
    `from`,
    `to`,
    toStartOfMinute(timestamp) AS minute
FROM trc20_transfer
WHERE year(timestamp) = 2023;

/* Backfill for 2018-2025 */