-- historical transfers aggregated by time (date, minute)
CREATE OR REPLACE VIEW trc20_transfer_by_time AS
SELECT
    -- order keys --
    log_address,
    account,
    date,
    minute,

    -- balances --
    sum(t.amount_in) AS amount_in,
    sum(t.amount_out) AS amount_out,

    -- stats --
    sum(t.transactions) AS total_transactions,
    min(t.min_timestamp) AS min_timestamp,
    max(t.max_timestamp) AS max_timestamp,
    min(t.min_block_num) AS min_block_num,
    max(t.max_block_num) AS max_block_num
FROM trc20_transfer_agg t
GROUP BY log_address, account, date, minute;
