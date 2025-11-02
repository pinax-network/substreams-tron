-- TRC20 `/balances` --
EXPLAIN indexes = 1, projections = 1
SELECT
    log_address as contract,
    account,
    balance,
    total_transactions,
    min_timestamp as first_update,
    max_timestamp as last_update
FROM trc20_balances
WHERE account = 'TF14bUwNRFbx8fJPzXuG1bUBYzsynFvjtJ'
ORDER BY last_update DESC
LIMIT 20;

-- TRC20 `/holders` --
EXPLAIN indexes = 1, projections = 1
WITH
'TRRGC2RvhFQP5RcDfPg91s6xok3PuP4gWD' AS token,
supply AS (
    SELECT total_active_supply
    FROM trc20_token_metadata
    WHERE log_address = token
)
SELECT
    account,
    balance / POW(10, 6) AS balance,
    Floor(b.balance / (SELECT * FROM supply) * 100, 4) AS percentage,
    total_transactions,
    min_timestamp as first_update,
    max_timestamp as last_update
FROM trc20_balances b
WHERE log_address = token AND balance > 0
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
