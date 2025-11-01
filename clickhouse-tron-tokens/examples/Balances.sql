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
    'TU1zTUZAiJQSLGpjdisabQLVqg9bw129bx' AS token
, transfer_out AS (
    SELECT log_address, `from` as account, -sum(amount) AS amount
    FROM trc20_transfer
    WHERE log_address = token
    GROUP BY log_address, `from`, `to`
), transfer_in AS (
    SELECT log_address, `to` as account, sum(amount) AS amount
    FROM trc20_transfer
    WHERE log_address = token
    GROUP BY log_address, `from`, `to`
)
SELECT
    log_address,
    account,
    -sum(amount) AS balance
FROM transfer_out, transfer_in
GROUP BY log_address, account
ORDER BY balance DESC
LIMIT 10;

-- Top 100 balances by holders of specific contract --
SELECT account, transfer_in - transfer_out as balance
FROM trc20_transfer_agg FINAL
WHERE interval_min = 1440
AND log_address='TU1zTUZAiJQSLGpjdisabQLVqg9bw129bx'
ORDER BY  balance
DESC LIMIT 100



SELECT log_address, sum(amount) AS balance
FROM trc20_transfer
WHERE
    log_address = 'TU1zTUZAiJQSLGpjdisabQLVqg9bw129bx' AND
    `from` = 'TD1QExVvf2suXDKcmnF6W9XLciCroAm1Q7'
GROUP BY log_address;


-- Using AggregatingMergeTree balances view --
WITH
'TRRGC2RvhFQP5RcDfPg91s6xok3PuP4gWD' AS token,
supply AS (
    SELECT sum(balance)
    FROM balances_by_log_address
    WHERE log_address = token AND balance > 0
    GROUP BY log_address
)
SELECT
    account,
    balance / POW(10, 6) AS balance,
    Floor(b.balance / (SELECT * FROM supply) * 100, 4) AS percentage,
    total_transactions,
    min_timestamp as first_update,
    max_timestamp as last_update
FROM balances_by_log_address b
WHERE log_address = token
ORDER BY balance DESC
LIMIT 20;

-- Using Summing MergeTree balances view --
WITH
'TRRGC2RvhFQP5RcDfPg91s6xok3PuP4gWD' AS token,
supply AS (
    SELECT sum(balance)
    FROM balances_sum_by_log_address
    WHERE log_address = token AND balance > 0
    GROUP BY log_address
)
SELECT
    account,
    balance / POW(10, 6) AS balance,
    Floor(b.balance / (SELECT * FROM supply) * 100, 4) AS percentage,
    total_transactions
FROM balances_sum_by_log_address b
WHERE log_address = token
ORDER BY balance DESC
LIMIT 20;

    ┌─log_address────────────────────────┬───────min_timestamp─┬───────max_timestamp─┬─min_block_num─┬─max_block_num─┬─block_num_diff─┬──count─┐
 1. │ TQLNpTDwUQfnvTojatqRSqPpmW9WwWvkem │ 2018-11-20 08:14:48 │ 2018-12-07 08:52:30 │       4247606 │       4734054 │         486448 │ 553469 │
 2. │ TFjVEQD7JajAoqNcS3D4KLi9AKbftAVDns │ 2018-11-22 04:40:15 │ 2018-12-22 15:40:06 │       4299924 │       5148562 │         848638 │   2057 │
 3. │ TCHm2fJxqHQnH4RGfE6fwdEU5rcMGZCqis │ 2018-11-26 09:29:30 │ 2019-07-18 09:46:42 │       4420797 │      11079632 │        6658835 │    201 │
 4. │ TU1zTUZAiJQSLGpjdisabQLVqg9bw129bx │ 2018-11-30 07:40:15 │ 2019-11-25 10:07:21 │       4533498 │      14809431 │       10275933 │   1543 │
 5. │ TUh2Gkq1ZkQyZyfc2KZ9JQsMavWaY3Cdma │ 2018-12-24 08:14:57 │ 2019-07-05 11:01:21 │       5195907 │      10708467 │        5512560 │   4694 │
 6. │ TKBURAzYP6hwcRWBzqZvqww2PZuBm5Lev7 │ 2018-12-26 12:03:57 │ 2019-06-28 12:51:42 │       5257787 │      10509250 │        5251463 │   4129 │
 7. │ TAuXsThKmMYZWJJwfkGipPNjGFvPyrjNnZ │ 2018-12-27 11:03:45 │ 2019-11-06 01:38:27 │       5285224 │      14252263 │        8967039 │   6793 │
 8. │ TDJY8rCeq5ixqmg7m74BwxRt9BVEoVZshB │ 2018-12-27 16:21:00 │ 2019-01-09 06:52:30 │       5291555 │       5653873 │         362318 │    472 │
 9. │ TMtq5VJwCJRLwuT4DD9fZ3kG7AbgbafMHH │ 2018-12-31 14:08:06 │ 2019-11-25 11:29:12 │       5403876 │      14811068 │        9407192 │  48794 │
10. │ TS7qKrrHe5GUJmpqo7s4tAPNcasPh7umFM │ 2019-01-02 14:38:12 │ 2019-08-02 18:26:54 │       5461873 │      11512644 │        6050771 │  10769 │
11. │ TVif6Avt3Q8FzcvQ3tTsziYEFran6D3Jvd │ 2019-01-03 07:47:57 │ 2019-04-22 11:48:45 │       5482439 │       8594854 │        3112415 │    270 │
12. │ TRRGC2RvhFQP5RcDfPg91s6xok3PuP4gWD │ 2019-01-03 10:30:33 │ 2019-01-04 09:06:09 │       5485690 │       5512770 │          27080 │    621 │
13. │ TQ7AaGYQmFjN9bip8B7o5Bjacp7BccADnS │ 2019-01-04 06:01:21 │ 2019-09-27 13:23:45 │       5509075 │      13115452 │        7606377 │    786 │
14. │ TPkQCvenqF3Jc1q4U5s3sv6oEGBwSE1UHk │ 2019-01-04 12:53:21 │ 2019-01-13 11:07:48 │       5517310 │       5773740 │         256430 │    340 │
15. │ TVj2YBFJgkg47eNcxYbcKueWErkhhkgpSo │ 2019-01-10 07:36:45 │ 2019-01-24 04:15:00 │       5683531 │       6069071 │         385540 │    106 │
16. │ TSKtrTVPuZcLkxnStFvNyr6qpDiDUyyQDN │ 2019-01-12 16:43:36 │ 2019-02-04 01:26:24 │       5751915 │       6381304 │         629389 │    107 │
17. │ TMi57NGsF1ahti92CJ2Ri4VCnHX37sc6FK │ 2019-01-14 07:27:24 │ 2019-06-09 09:02:24 │       5797270 │       9962552 │        4165282 │   3133 │
18. │ TDc7VA3GwWQALWVD6hfz7CAwQruNH6utWW │ 2019-01-15 14:22:21 │ 2019-02-18 17:40:30 │       5833050 │       6803328 │         970278 │    727 │
19. │ TWuPP1HSQmDnp6XLH1o2koSkRo281JKWmd │ 2019-01-18 11:26:09 │ 2019-01-26 04:35:18 │       5907966 │       6126618 │         218652 │    710 │
20. │ TR6UJ8QZfhRw1QZm2UDgdYcP5hqpgYdd9R │ 2019-01-21 07:14:00 │ 2019-01-24 06:06:12 │       5987000 │       6071254 │          84254 │    175 │
    └────────────────────────────────────┴─────────────────────┴─────────────────────┴───────────────┴───────────────┴────────────────┴────────┘