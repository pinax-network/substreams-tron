-- TRC20 token transfer summary
-- For `/holders` queries
CREATE TABLE IF NOT EXISTS trc20_transfer_sum (
    -- order keys --
    log_address                 LowCardinality(String),
    account                     String,

    -- transfers in/out --
    amount_in                   UInt256 COMMENT 'Amount received by account',
    amount_out                  UInt256 COMMENT 'Amount sent by account',
    amount                      Int256 COMMENT 'Delta amount for account (+in, -out)',

    -- stats --
    transactions                UInt64 COMMENT 'Number of transactions for account on this date',

    -- indexes - order keys --
    INDEX idx_log_address (log_address) TYPE bloom_filter GRANULARITY 1,

    -- indexes - transfer in/out & stats --
    INDEX idx_amount_in (amount_in) TYPE minmax GRANULARITY 1,
    INDEX idx_amount_out (amount_out) TYPE minmax GRANULARITY 1,
    INDEX idx_amount (amount) TYPE minmax GRANULARITY 1,

    -- indexes - stats --
    INDEX idx_transactions (transactions) TYPE minmax GRANULARITY 1
)
ENGINE = SummingMergeTree
ORDER BY (log_address, account)
COMMENT 'TRC20 token transfer summarized';

-- Materialized view for TRC20 transfer summary
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_sum
TO trc20_transfer_sum
AS
-- +credits: to-account receives amount
SELECT
    -- order keys --
    log_address,
    `to` AS account,

    -- transfers in/out --
    sum(t.amount) AS amount_in,
    sum(toInt256(t.amount)) AS amount,

    -- stats --
    count() AS transactions
FROM trc20_transfer t
GROUP BY log_address, account

UNION ALL

-- -debits: from-account sends amount (negative delta)
SELECT
    -- order keys --
    log_address,
    `from` AS account,

    -- transfers in/out --
    sum(t.amount) AS amount_out,
    -sum(toInt256(t.amount)) AS amount,

    -- stats --
    count() AS transactions
FROM trc20_transfer as t
GROUP BY log_address, account;
