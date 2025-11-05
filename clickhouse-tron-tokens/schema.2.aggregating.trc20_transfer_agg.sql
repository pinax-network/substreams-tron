-- Table for TRC20 transfer aggregated stats
-- used for `/holders`, `/balances`, `/tokens` (supply) and `/historical/balances` queries
CREATE TABLE IF NOT EXISTS trc20_transfer_agg (
    -- order keys --
    log_address         LowCardinality(String) COMMENT 'token contract address',
    account             LowCardinality(String) COMMENT 'account address',
    date                Date COMMENT 'date of the transfers',
    -- minute              UInt32 COMMENT 'minute of the transfers',

    -- transfers in/out --
    amount_in           SimpleAggregateFunction(sum, UInt256) COMMENT 'Total amount received by account',
    amount_out          SimpleAggregateFunction(sum, UInt256) COMMENT 'Total amount sent by account',
    amount_delta        SimpleAggregateFunction(sum, Int256) COMMENT 'Net delta amount for account (+in, -out)',

    -- stats --
    min_timestamp       SimpleAggregateFunction(min, DateTime('UTC')) COMMENT 'Timestamp of first transfer for account',
    max_timestamp       SimpleAggregateFunction(max, DateTime('UTC')) COMMENT 'Timestamp of last transfer for account',
    min_block_num       SimpleAggregateFunction(min, UInt32) COMMENT 'Block number of first transfer for account',
    max_block_num       SimpleAggregateFunction(max, UInt32) COMMENT 'Block number of last transfer for account',
    transactions_in     SimpleAggregateFunction(sum, UInt64) COMMENT 'Total number of incoming transfers for account',
    transactions_out    SimpleAggregateFunction(sum, UInt64) COMMENT 'Total number of outgoing transfers for account',
    transactions        SimpleAggregateFunction(sum, UInt64) COMMENT 'Total number of transfers for account',

    -- indexes - order keys--
    INDEX idx_log_address (log_address) TYPE bloom_filter GRANULARITY 1,
    -- INDEX idx_minute (minute) TYPE minmax GRANULARITY 1,

    -- indexes -- transfer in/out & stats --
    INDEX idx_amount_in (amount_in) TYPE minmax GRANULARITY 1,
    INDEX idx_amount_out (amount_out) TYPE minmax GRANULARITY 1,
    INDEX idx_amount_delta (amount_delta) TYPE minmax GRANULARITY 1,

    -- stats indexes --
    INDEX idx_min_timestamp (min_timestamp) TYPE minmax GRANULARITY 1,
    INDEX idx_max_timestamp (max_timestamp) TYPE minmax GRANULARITY 1,
    INDEX idx_min_block_num (min_block_num) TYPE minmax GRANULARITY 1,
    INDEX idx_max_block_num (max_block_num) TYPE minmax GRANULARITY 1,
    INDEX idx_transactions (transactions) TYPE minmax GRANULARITY 1,
    INDEX idx_transactions_in (transactions_in) TYPE minmax GRANULARITY 1,
    INDEX idx_transactions_out (transactions_out) TYPE minmax GRANULARITY 1
)
ENGINE = AggregatingMergeTree
ORDER BY (account, log_address, date);

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
            sum(amount_delta),

            -- stats --
            count(),
            min(min_timestamp),
            max(max_timestamp),
            min(min_block_num),
            max(max_block_num),
            sum(transactions),
            sum(transactions_in),
            sum(transactions_out)
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
            sum(amount_delta),

            -- stats --
            count(),
            min(min_timestamp),
            max(max_timestamp),
            min(min_block_num),
            max(max_block_num),
            sum(transactions),
            sum(transactions_in),
            sum(transactions_out)
        GROUP BY account, log_address
    ),
    -- used for token metadata queries
    ADD PROJECTION IF NOT EXISTS prj_log_address (
        SELECT
            -- order keys --
            log_address,

            -- balances --
            sum(amount_in),
            sum(amount_out),
            sum(amount_delta),

            -- stats --
            count(),
            min(min_timestamp),
            max(max_timestamp),
            min(min_block_num),
            max(max_block_num),
            sum(transactions),
            sum(transactions_in),
            sum(transactions_out)
        GROUP BY log_address
    ),
    -- used to lookup all accounts with activity in a date range
    ADD PROJECTION IF NOT EXISTS prj_account (
        SELECT
            -- order keys --
            account,

            -- stats --
            count(),
            min(min_timestamp),
            max(max_timestamp),
            min(min_block_num),
            max(max_block_num),
            sum(transactions),
            sum(transactions_in),
            sum(transactions_out)
        GROUP BY account
    );

-- +credits: to-account receives amount
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_transfer_agg
TO trc20_transfer_agg AS
WITH transfers AS (
    SELECT
        -- order keys --
        log_address,
        `to` AS account,

        -- timeseries --
        timestamp,
        block_num,

        -- transfers in/out --
        amount AS amount_in,
        0 AS amount_out,
        toInt256(amount) AS amount_delta,
        1 AS transactions_in,
        0 AS transactions_out,
        1 AS transactions
    FROM trc20_transfer

    UNION ALL

    -- -debits: from-account sends amount (negative delta)
    SELECT
        -- order keys --
        log_address,
        `from` AS account,

        -- timeseries --
        timestamp,
        block_num,

        -- transfers in/out --
        0 AS amount_in,
        amount AS amount_out,
        -toInt256(amount) AS amount_delta,
        0 AS transactions_in,
        1 AS transactions_out,
        1 AS transactions
    FROM trc20_transfer
) SELECT
    -- order keys --
    log_address,
    account,
    date(timestamp) AS date,

    -- transfers in/out --
    sum(amount_in) AS amount_in,
    sum(amount_out) AS amount_out,
    sum(amount_delta) AS amount_delta,

    -- stats --
    min(timestamp) AS min_timestamp,
    max(timestamp) AS max_timestamp,
    min(block_num) AS min_block_num,
    max(block_num) AS max_block_num,
    sum(transactions) AS transactions,
    sum(transactions_in) AS transactions_in,
    sum(transactions_out) AS transactions_out
FROM transfers
GROUP BY log_address, account, date;
