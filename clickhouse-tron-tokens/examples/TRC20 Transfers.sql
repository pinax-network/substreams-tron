
-- TRC20 `/historical/transfers` --
EXPLAIN indexes = 1, projections = 1
SELECT log_address, account, date, amount_in, amount_out,amount_delta
FROM trc20_transfer_by_time
ORDER BY date DESC
LIMIT 20;

-- Check incoming & outgoing transfers for an account
WITH transfers AS (
    SELECT
        log_address AS contract,
        -sum(toInt256(amount)) AS amount
    FROM trc20_transfer
    WHERE log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t' AND `from` = 'THDW2bQZicUiuJxkWHhtmva9b37JFWnMf4'
    GROUP BY contract

    UNION ALL

    SELECT
        log_address AS contract,
        sum(toInt256(amount)) AS amount
    FROM trc20_transfer
    WHERE log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t' AND `to` = 'THDW2bQZicUiuJxkWHhtmva9b37JFWnMf4'
    GROUP BY contract
) SELECT
    contract,
    sum(amount) AS balance
FROM transfers
GROUP BY contract;

-- Lookup Top Active Tokens
EXPLAIN indexes = 1, projections = 1
WITH transfers AS (
    SELECT
        log_address,
        min(min_timestamp) AS min_timestamp,
        max(max_timestamp) AS max_timestamp,
        count() as count
    FROM trc20_transfer_agg
    GROUP BY log_address
)
SELECT
    log_address,
    min_timestamp,
    max_timestamp,
    abi_hex_to_string(m.name_hex) AS name,
    abi_hex_to_string(m.symbol_hex) AS symbol,
    count
FROM transfers
JOIN `tron:tvm-tokens@v0.1.1`.metadata_rpc AS m ON transfers.log_address = m.contract
ORDER BY count DESC
LIMIT 20;