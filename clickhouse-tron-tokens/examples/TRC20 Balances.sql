-- TRC20 `/balances` --
EXPLAIN indexes = 1, projections = 1
SELECT
    account,
    log_address as contract,
    abi_hex_to_string(m.name_hex) AS name,
    abi_hex_to_string(m.symbol_hex) AS symbol,
    abi_hex_to_uint8(m.decimals_hex) AS decimals,
    balance as amount,
    balance / pow(10, abi_hex_to_uint8(m.decimals_hex)) AS value,
    max_timestamp as last_update,
    max_block_num as last_update_block_num,
    toUnixTimestamp(max_timestamp) as last_update_timestamp
FROM trc20_balances
JOIN `tron:tvm-tokens@v0.1.1`.metadata_rpc AS m ON trc20_balances.log_address = m.contract
WHERE account = 'TVUkNconSCD6WQN7tYibsj4YN7ABKLap4R' AND balance > 0
ORDER BY max_timestamp DESC
LIMIT 20;

-- TRC20 `/holders` --
EXPLAIN indexes = 1, projections = 1
SELECT
    account,
    balance as amount,
    balance / pow(10, abi_hex_to_uint8(m.decimals_hex)) AS value,
    abi_hex_to_string(m.name_hex) AS name,
    abi_hex_to_string(m.symbol_hex) AS symbol,
    abi_hex_to_uint8(m.decimals_hex) AS decimals
FROM trc20_balances b
JOIN `tron:tvm-tokens@v0.1.1`.metadata_rpc AS m ON b.log_address = m.contract
WHERE log_address = 'TNUC9Qb1rRpS5CbWLmNMxXBjyFoydXjWFR' AND balance > 0
ORDER BY balance DESC
LIMIT 20;

-- Token Metadata
EXPLAIN indexes = 1, projections = 1
SELECT *
FROM trc20_token_metadata
WHERE log_address = 'TRRGC2RvhFQP5RcDfPg91s6xok3PuP4gWD';

-- Top 20 tokens by number of holders --
EXPLAIN indexes = 1, projections = 1
SELECT *
FROM trc20_token_metadata
ORDER BY holders DESC
LIMIT 20;
