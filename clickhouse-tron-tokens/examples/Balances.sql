-- All balances for specific account --
EXPLAIN indexes = 1, projections = 1
WITH
    ['TCfeM1VFrBmCkL92pcrtWW61uJQYb91uwM'] AS accounts
, transfer_out AS (
    SELECT log_address, `from` as account, -sum(amount) AS amount
    FROM trc20_transfer
    WHERE `from` IN accounts
    GROUP BY log_address, `from`
), transfer_in AS (
    SELECT log_address, `to` as account, sum(amount) AS amount
    FROM trc20_transfer
    WHERE `to` IN accounts
    GROUP BY log_address, `to`
)
SELECT
    log_address,
    account,
    sum(amount) AS balance
FROM transfer_out, transfer_in
GROUP BY log_address, account;

-- All balances by holders of specific contract --
-- All balances for specific account --
EXPLAIN indexes = 1, projections = 1
WITH
    'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t' AS token
, transfer_out AS (
    SELECT log_address, `from` as account, -sum(amount) AS amount
    FROM trc20_transfer
    WHERE log_address = token
    GROUP BY log_address, `from`
), transfer_in AS (
    SELECT log_address, `to` as account, sum(amount) AS amount
    FROM trc20_transfer
    WHERE log_address = token
    GROUP BY log_address, `to`
)
SELECT
    log_address,
    account,
    sum(amount) AS balance
FROM transfer_out, transfer_in
GROUP BY log_address, account;