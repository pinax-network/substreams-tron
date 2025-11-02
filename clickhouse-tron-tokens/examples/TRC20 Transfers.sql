
-- TRC20 `/historical/transfers` --
EXPLAIN indexes = 1, projections = 1
SELECT
    log_address as contract,
    account,
    amount_in,
    amount_out,
    date,
    minute,
    total_transactions,
    min_timestamp as first_update,
    max_timestamp as last_update
FROM trc20_transfer_by_time
ORDER BY minute DESC;