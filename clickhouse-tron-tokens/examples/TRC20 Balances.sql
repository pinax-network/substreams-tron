-- TRC20 `/balances` --
EXPLAIN indexes = 1, projections = 1
SELECT *
FROM trc20_balances
WHERE account = 'TF14bUwNRFbx8fJPzXuG1bUBYzsynFvjtJ'
-- WHERE account = 'THmodWGbySJqCkYUQfx92bgCUPtjaeFgPw'
ORDER BY max_timestamp DESC
LIMIT 20;

-- TRC20 `/holders` --
EXPLAIN indexes = 1, projections = 1
WITH
'TRRGC2RvhFQP5RcDfPg91s6xok3PuP4gWD' AS token,
-- 'TY5NJKhJFkipYDokTAgo8TtzTwpicXNoCQ' AS token,
supply AS (
    SELECT log_address, total_active_supply
    FROM trc20_token_metadata
    WHERE log_address = token
)
SELECT
    account,
    balance,
    Floor(b.balance / s.total_active_supply * 100, 4) AS percentage,
    total_transactions,
    total_transactions_in,
    total_transactions_out,
    min_timestamp,
    max_timestamp
FROM trc20_balances b
JOIN supply s USING (log_address)
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
