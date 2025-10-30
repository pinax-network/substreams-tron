CREATE TABLE IF NOT EXISTS trc20_transfer_by_log_address (
    log_address                 String,
    minute                      UInt32,

    -- indexes --
    INDEX idx_minute            (minute) TYPE minmax GRANULARITY 8
)
ENGINE = ReplacingMergeTree
ORDER BY (log_address, minute)
COMMENT 'Transfer events grouped by log address (e.g., token contract) and minute';

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_by_log_address
TO trc20_transfer_by_log_address AS
SELECT
    log_address,
    toRelativeMinuteNum(timestamp) AS minute
FROM trc20_transfer
GROUP BY log_address, minute;

CREATE TABLE IF NOT EXISTS trc20_transfer_by_from (
    `from`                  String,
    minute                  UInt32,

    -- indexes --
    INDEX idx_minute        (minute) TYPE minmax GRANULARITY 8
)
ENGINE = ReplacingMergeTree
ORDER BY (`from`, minute)
COMMENT 'Transfer events grouped by log address (e.g., token contract) and minute';

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_by_from
TO trc20_transfer_by_from AS
SELECT
    `from`,
    toRelativeMinuteNum(timestamp) AS minute
FROM trc20_transfer
GROUP BY `from`, minute;

CREATE TABLE IF NOT EXISTS trc20_transfer_by_to (
    `to`                        String,
    minute                      UInt32,

    -- indexes --
    INDEX idx_minute            (minute) TYPE minmax GRANULARITY 8
)
ENGINE = ReplacingMergeTree
ORDER BY (`to`, minute)
COMMENT 'Transfer events grouped by log address (e.g., token contract) and minute';

CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_by_to
TO trc20_transfer_by_to AS
SELECT
    `to`,
    toRelativeMinuteNum(timestamp) AS minute
FROM trc20_transfer
GROUP BY `to`, minute;
