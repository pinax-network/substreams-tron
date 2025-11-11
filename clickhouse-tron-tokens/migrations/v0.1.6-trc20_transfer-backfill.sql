INSERT INTO trc20_transfer_relative_minutes
SELECT
    log_address,
    `from`,
    `to`,
    toRelativeMinuteNum(t.minute) AS minute
FROM trc20_transfer_minutes AS t
WHERE year(t.minute) < 2020;

/* Backfill for 2018-2025 */