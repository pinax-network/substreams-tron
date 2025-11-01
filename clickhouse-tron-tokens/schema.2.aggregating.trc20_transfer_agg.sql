-- Table for TRC20 transfer aggregated stats
CREATE TABLE IF NOT EXISTS trc20_transfer_agg (
    -- order keys --
    log_address         LowCardinality(String) COMMENT 'token contract address',
    account             LowCardinality(String) COMMENT 'account address',
    date                Date COMMENT 'date of the stats',

    -- transfers in/out --
    amount_in           SimpleAggregateFunction(sum, UInt256) COMMENT 'Total amount received by account',
    amount_out          SimpleAggregateFunction(sum, UInt256) COMMENT 'Total amount sent by account',
    amount              SimpleAggregateFunction(sum, Int256) COMMENT 'Net delta amount for account (+in, -out)',

    -- stats --
    min_timestamp       SimpleAggregateFunction(min, DateTime('UTC')) COMMENT 'Timestamp of first transfer for account',
    max_timestamp       SimpleAggregateFunction(max, DateTime('UTC')) COMMENT 'Timestamp of last transfer for account',
    min_block_num       SimpleAggregateFunction(min, UInt32) COMMENT 'Block number of first transfer for account',
    max_block_num       SimpleAggregateFunction(max, UInt32) COMMENT 'Block number of last transfer for account',
    transactions        SimpleAggregateFunction(sum, UInt64) COMMENT 'Total number of transfers for account',

    -- indexes - order keys--
    INDEX idx_log_address (log_address) TYPE bloom_filter GRANULARITY 1,
    INDEX idx_date (date) TYPE minmax GRANULARITY 1,

    -- indexes -- transfer in/out & stats --
    INDEX idx_amount_in (amount_in) TYPE minmax GRANULARITY 1,
    INDEX idx_amount_out (amount_out) TYPE minmax GRANULARITY 1,
    INDEX idx_amount (amount) TYPE minmax GRANULARITY 1,

    -- stats indexes --
    INDEX idx_min_timestamp (min_timestamp) TYPE minmax GRANULARITY 1,
    INDEX idx_max_timestamp (max_timestamp) TYPE minmax GRANULARITY 1,
    INDEX idx_min_block_num (min_block_num) TYPE minmax GRANULARITY 1,
    INDEX idx_max_block_num (max_block_num) TYPE minmax GRANULARITY 1,
    INDEX idx_transactions (transactions) TYPE minmax GRANULARITY 1
)
ENGINE = AggregatingMergeTree
ORDER BY (account, log_address, date);

-- Settings and projections --
ALTER TABLE trc20_transfer_agg
    MODIFY SETTING deduplicate_merge_projection_mode = 'rebuild';
ALTER TABLE trc20_transfer_agg
    ADD PROJECTION IF NOT EXISTS prj_log_address_account (SELECT * ORDER BY (log_address, account));

-- For `/holders` queries
CREATE TABLE IF NOT EXISTS trc20_transfer_agg_by_log_address AS trc20_transfer_agg
ORDER BY (log_address, account)
COMMENT 'TRC20 token transfer aggregated by (log_address, account)';
ALTER TABLE trc20_transfer_agg_by_log_address
    DROP INDEX IF EXISTS idx_log_address,
    ADD INDEX IF NOT EXISTS idx_account (account) TYPE bloom_filter GRANULARITY 1;

-- Materialized view for TRC20 transfer aggregated stats
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_agg
TO trc20_transfer_agg AS
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
    min(t.timestamp) AS min_timestamp,
    max(t.timestamp) AS max_timestamp,
    min(t.block_num) AS min_block_num,
    max(t.block_num) AS max_block_num,
    count() AS transactions
FROM trc20_transfer t
GROUP BY log_address, account, date

UNION ALL

SELECT
    -- order keys --
    log_address,
    `from` AS account,
    date(t.timestamp) AS date,

    -- transfers in/out --
    sum(t.amount) AS amount_out,
    -sum(toInt256(t.amount)) AS amount,

    -- stats --
    min(t.timestamp) AS min_timestamp,
    max(t.timestamp) AS max_timestamp,
    min(t.block_num) AS min_block_num,
    max(t.block_num) AS max_block_num,
    count() AS transactions
FROM trc20_transfer t
GROUP BY log_address, account, date;

-- Materialized view for TRC20 transfer summary by (log_address, account)
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_agg_by_log_address
TO trc20_transfer_agg_by_log_address
AS
SELECT *
FROM trc20_transfer_agg;

-- Views for balances derived from trc20_transfer table --
CREATE OR REPLACE VIEW balances AS
SELECT
    -- order keys --
    log_address,
    account,

    -- balances --
    sum(t.amount) AS balance,

    -- stats --
    sum(t.transactions) AS total_transactions,
    min(t.min_timestamp) AS min_timestamp,
    max(t.max_timestamp) AS max_timestamp,
    min(t.min_block_num) AS min_block_num,
    max(t.max_block_num) AS max_block_num
FROM trc20_transfer_agg t
GROUP BY log_address, account;

CREATE OR REPLACE VIEW balances_by_log_address AS
SELECT
    -- order keys --
    log_address,
    account,

    -- balances --
    sum(t.amount) AS balance,

    -- stats --
    sum(t.transactions) AS total_transactions,
    min(t.min_timestamp) AS min_timestamp,
    max(t.max_timestamp) AS max_timestamp,
    min(t.min_block_num) AS min_block_num,
    max(t.max_block_num) AS max_block_num
FROM trc20_transfer_agg_by_log_address t
GROUP BY log_address, account;

CREATE OR REPLACE VIEW token_metadata AS
SELECT
    -- order keys --
    log_address,

    -- holders --
    count() AS holders,

    -- supply --
    sum(balance) AS total_active_supply,

    -- stats --
    sum(total_transactions) AS total_transactions,
    min(min_timestamp) AS min_timestamp,
    max(max_timestamp) AS max_timestamp,
    min(min_block_num) AS min_block_num,
    max(max_block_num) AS max_block_num
FROM balances_by_log_address
WHERE balance > 0
GROUP BY log_address;
