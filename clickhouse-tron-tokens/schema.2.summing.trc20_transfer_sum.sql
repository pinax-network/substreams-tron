-- TRC20 token transfer summary
-- for `/balances` queries
CREATE TABLE IF NOT EXISTS trc20_transfer_sum (
    -- order keys --
    log_address                 LowCardinality(String),
    account                     String,
    date                        Date COMMENT 'Date of the transfer',

    -- transfers in/out --
    amount_in                   UInt256 COMMENT 'Amount received by account',
    amount_out                  UInt256 COMMENT 'Amount sent by account',
    amount                      Int256 COMMENT 'Delta amount for account (+in, -out)',

    -- stats --
    transactions                UInt64 COMMENT 'Number of transactions for account on this date',

    -- indexes - order keys --
    INDEX idx_log_address (log_address) TYPE bloom_filter GRANULARITY 1,
    INDEX idx_date (date) TYPE minmax GRANULARITY 1,

    -- indexes - transfer in/out & stats --
    INDEX idx_amount_in (amount_in) TYPE minmax GRANULARITY 1,
    INDEX idx_amount_out (amount_out) TYPE minmax GRANULARITY 1,
    INDEX idx_amount (amount) TYPE minmax GRANULARITY 1,

    -- indexes - stats --
    INDEX idx_transactions (transactions) TYPE minmax GRANULARITY 1
)
ENGINE = SummingMergeTree
ORDER BY (account, log_address, date)
COMMENT 'TRC20 token transfer summarized by (account, log_address, date)';

-- For `/holders` queries
CREATE TABLE IF NOT EXISTS trc20_transfer_sum_by_log_address AS trc20_transfer_sum
ORDER BY (log_address, account)
COMMENT 'TRC20 token transfer summarized by (log_address, account)';
ALTER TABLE trc20_transfer_sum
    DROP INDEX IF EXISTS idx_log_address,
    ADD INDEX IF NOT EXISTS idx_account (account) TYPE bloom_filter GRANULARITY 1;

-- Materialized view for TRC20 transfer summary
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_sum
TO trc20_transfer_sum
AS
-- +credits: to-account receives amount
SELECT
    -- order keys --
    log_address,
    `to` AS account,
    date(t.timestamp) AS date,

    -- transfers in/out --
    sum(t.amount) AS amount_in,
    sum(toInt256(t.amount)) AS amount,

    -- stats --
    count() AS transactions
FROM trc20_transfer t
GROUP BY log_address, account, date

UNION ALL

-- -debits: from-account sends amount (negative delta)
SELECT
    -- order keys --
    log_address,
    `from` AS account,
    date(t.timestamp) AS date,

    -- transfers in/out --
    sum(t.amount) AS amount_out,
    -sum(toInt256(t.amount)) AS amount,

    -- stats --
    count() AS transactions
FROM trc20_transfer as t
GROUP BY log_address, account, date;

-- Materialized view for TRC20 transfer summary by (log_address, account)
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_sum_by_log_address
TO trc20_transfer_sum_by_log_address
AS
SELECT *
FROM trc20_transfer_sum;

-- Views for balances and token metadata
CREATE OR REPLACE VIEW balances_sum AS
SELECT
    log_address,
    account,
    sum(t.amount) AS balance,
    sum(t.transactions) AS total_transactions
FROM trc20_transfer_sum t
GROUP BY log_address, account;

CREATE OR REPLACE VIEW balances_sum_by_log_address AS
SELECT
    log_address,
    account,
    sum(t.amount) AS balance,
    sum(t.transactions) AS total_transactions
FROM trc20_transfer_sum t
GROUP BY log_address, account;

CREATE OR REPLACE VIEW token_metadata_sum AS
SELECT
    log_address,
    count() AS holders,
    sum(balance) AS total_active_supply,
    sum(total_transactions) AS total_transactions
FROM balances_sum_by_log_address
WHERE balance > 0
GROUP BY log_address;
