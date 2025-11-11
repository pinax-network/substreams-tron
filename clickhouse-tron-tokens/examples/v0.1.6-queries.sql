WITH minutes AS (
    SELECT toRelativeMinuteNum(timestamp) AS minute
    FROM trc20_transfer
    WHERE `from` = 'TAYtGZzxZf1GhPfGwZKskWQnz7Qj3rwLDh'
    GROUP BY minute
)
SELECT * FROM trc20_transfer
WHERE toRelativeMinuteNum(timestamp) IN minutes
LIMIT 10