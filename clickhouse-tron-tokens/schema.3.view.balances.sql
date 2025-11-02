-- Views for balances derived from trc20_transfer table --
-- for `/balances`, `/holders`
CREATE OR REPLACE VIEW trc20_balances AS
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

-- TRC20 Token Metadata View
-- for `/tokens` queries
CREATE OR REPLACE VIEW trc20_token_metadata AS
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
FROM trc20_balances
WHERE balance > 0
GROUP BY log_address;
