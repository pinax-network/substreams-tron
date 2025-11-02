
-- TRC20 `/historical/transfers` --
EXPLAIN indexes = 1, projections = 1
SELECT log_address, account, date, amount_in, amount_out,amount_delta
FROM trc20_transfer_by_time
ORDER BY date DESC;