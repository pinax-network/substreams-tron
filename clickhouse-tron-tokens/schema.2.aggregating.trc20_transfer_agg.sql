-- Table for TRC20 transfer aggregated stats
-- used for `/holders`, `/balances`, `/tokens` (supply) and `/historical/balances` queries
CREATE TABLE IF NOT EXISTS trc20_transfer_agg (
    -- order keys --
    log_address         LowCardinality(String) COMMENT 'token contract address',
    account             LowCardinality(String) COMMENT 'account address',
    date                Date COMMENT 'date of the transfers',
    minute              UInt32 COMMENT 'minute of the transfers',

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
    INDEX idx_minute (minute) TYPE minmax GRANULARITY 1,

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
ORDER BY (account, log_address, date, minute);

-- Settings and projections --

-- Settings and projections --
ALTER TABLE trc20_transfer_agg
    MODIFY SETTING deduplicate_merge_projection_mode = 'rebuild';
ALTER TABLE trc20_transfer_agg
    -- projections --
    -- used for `/holders` & `/tokens` (supply)
    ADD PROJECTION IF NOT EXISTS prj_log_address_account (
        SELECT
            -- order keys --
            log_address,
            account,

            -- balances --
            sum(amount_in),
            sum(amount_out),
            sum(amount),

            -- stats --
            sum(transactions),
            min(min_timestamp),
            max(max_timestamp),
            min(min_block_num),
            max(max_block_num)
        GROUP BY log_address, account
    ),
    -- used for `/balances`
    ADD PROJECTION IF NOT EXISTS prj_account_log_address (
        SELECT
            -- order keys --
            log_address,
            account,

            -- balances --
            sum(amount_in),
            sum(amount_out),
            sum(amount),

            -- stats --
            sum(transactions),
            min(min_timestamp),
            max(max_timestamp),
            min(min_block_num),
            max(max_block_num)
        GROUP BY account, log_address
    );


-- Materialized view for TRC20 transfer aggregated stats
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_agg
TO trc20_transfer_agg AS
-- +credits: to-account receives amount
SELECT
    -- order keys --
    log_address,
    `to` AS account,
    date(t.timestamp) AS date,
    toRelativeMinuteNum(t.timestamp) AS minute,

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
GROUP BY account, log_address, date, minute

UNION ALL

SELECT
    -- order keys --
    log_address,
    `from` AS account,
    date(t.timestamp) AS date,
    toRelativeMinuteNum(t.timestamp) AS minute,

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
GROUP BY account, log_address, date, minute;
