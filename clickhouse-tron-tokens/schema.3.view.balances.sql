-- Views for balances derived from trc20_transfer table --
-- for `/balances`, `/holders`
CREATE OR REPLACE VIEW trc20_balances AS
SELECT
    -- order keys --
    log_address,
    account,

    -- balances --
    sum(amount_delta) AS balance,

    -- stats --
    sum(transactions) AS total_transactions,
    min(min_timestamp) AS min_timestamp,
    max(max_timestamp) AS max_timestamp,
    min(min_block_num) AS min_block_num,
    max(max_block_num) AS max_block_num
FROM trc20_transfer_agg
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
