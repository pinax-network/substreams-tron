INSERT INTO trc20_transfer_minutes
SELECT
    log_address,
    `from`,
    `to`,
    toStartOfMinute(timestamp) AS minute
FROM trc20_transfer
WHERE year(timestamp) < 2023;