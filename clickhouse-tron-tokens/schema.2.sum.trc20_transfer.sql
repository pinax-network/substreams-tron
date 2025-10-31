-- OHLCV prices --
CREATE TABLE IF NOT EXISTS trc20_transfer_in_sum (
    -- order keys --
    log_address             LowCardinality(String),
    account                 String,

    -- transfers --
    amount                  UInt256,

    -- indexes --
    INDEX idx_account           (account)           TYPE bloom_filter           GRANULARITY 1,
)
ENGINE = SummingMergeTree(amount)
ORDER BY (log_address, account)
COMMENT 'TRC20 token transfer incoming amounts aggregated by (log_address, to-account)';

CREATE TABLE IF NOT EXISTS trc20_transfer_out_sum AS trc20_transfer_in_sum
ENGINE = SummingMergeTree(amount)
ORDER BY (log_address, account)
COMMENT 'TRC20 token transfer outgoing amounts aggregated by (log_address, from-account)';

-- +credits: to-account receives amount
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_in_sum
TO trc20_transfer_in_sum
AS
SELECT
    log_address,
    `to`                AS account,
    amount              AS amount
FROM trc20_transfer;

-- -debits: from-account sends amount (negative delta)
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_out_sum
TO trc20_transfer_out_sum
AS
SELECT
    log_address,
    `from`              AS account,
    amount              AS amount
FROM trc20_transfer;

CREATE OR REPLACE VIEW balances AS
SELECT
    account,
    toInt256(SUM(in_amt)) - toInt256(SUM(out_amt)) AS balance
FROM
(
    -- incoming (credits)
    SELECT
        log_address,
        account,
        SUM(amount) AS in_amt,
        0 AS out_amt
    FROM trc20_transfer_in_sum
    WHERE log_address = 'TRRGC2RvhFQP5RcDfPg91s6xok3PuP4gWD'
    GROUP BY log_address, account

    UNION ALL

    -- outgoing (debits)
    SELECT
        log_address,
        account,
        0 AS in_amt,
        SUM(amount) AS out_amt
    FROM trc20_transfer_out_sum
    WHERE log_address = 'TRRGC2RvhFQP5RcDfPg91s6xok3PuP4gWD'
    GROUP BY log_address, account
)
GROUP BY log_address, account
HAVING balance > 0
ORDER BY balance DESC;