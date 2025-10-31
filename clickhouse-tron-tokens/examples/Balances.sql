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

    ┌─log_address────────────────────────┬───────min_timestamp─┬───────max_timestamp─┬─min_block_num─┬─max_block_num─┬─block_num_diff─┬──count─┐
 1. │ TQLNpTDwUQfnvTojatqRSqPpmW9WwWvkem │ 2018-11-20 08:14:48 │ 2018-12-07 08:52:30 │       4247606 │       4734054 │         486448 │ 553469 │
 2. │ TBHN6guS6ztVVXbFivajdG3PxFUZ5UXGxY │ 2018-11-20 08:15:15 │ 2019-03-02 05:52:57 │       4247615 │       7134287 │        2886672 │ 216344 │
 3. │ TFjVEQD7JajAoqNcS3D4KLi9AKbftAVDns │ 2018-11-22 04:40:15 │ 2018-12-22 15:40:06 │       4299924 │       5148562 │         848638 │   2057 │
 4. │ TCHm2fJxqHQnH4RGfE6fwdEU5rcMGZCqis │ 2018-11-26 09:29:30 │ 2019-02-15 06:39:33 │       4420797 │       6703813 │        2283016 │    183 │
 5. │ TU1zTUZAiJQSLGpjdisabQLVqg9bw129bx │ 2018-11-30 07:40:15 │ 2019-03-04 09:56:21 │       4533498 │       7196586 │        2663088 │   1542 │
 6. │ TVeQmdceGXgFDSgfqqfHSSfxz4ucSmGjJA │ 2018-11-30 11:40:18 │ 2019-03-04 13:57:30 │       4538299 │       7201400 │        2663101 │   7084 │
 7. │ TC6quQTBkZg3jct3Wd1k2Au4u9tdQkQnnL │ 2018-12-04 08:30:06 │ 2019-03-03 06:06:03 │       4647914 │       7163290 │        2515376 │   6219 │
 8. │ TLf7WJDueroFmpMZpfg3DfyeK52VvShdj2 │ 2018-12-15 12:30:00 │ 2019-02-26 08:33:48 │       4962441 │       7022560 │        2060119 │   2368 │
 9. │ TPuy387tm5Ehm7KiNUzSaMG7BwkRDJDpyv │ 2018-12-19 10:40:51 │ 2019-01-20 15:24:24 │       5066626 │       5968245 │         901619 │   1476 │
10. │ THNrGgy8mWjhcxLB5PR5hiJUfkM9rqYaBZ │ 2018-12-20 03:34:00 │ 2018-12-20 04:17:12 │       5086566 │       5087404 │            838 │   7733 │
11. │ TF6i3aPkvhQ7Whqa8UDs7VXVhtURasnAMk │ 2018-12-22 02:33:33 │ 2019-03-03 18:03:12 │       5132916 │       7177610 │        2044694 │    316 │
12. │ TAuXsThKmMYZWJJwfkGipPNjGFvPyrjNnZ │ 2018-12-27 11:03:45 │ 2019-02-03 16:03:30 │       5285224 │       6370064 │        1084840 │   6792 │
13. │ TDJY8rCeq5ixqmg7m74BwxRt9BVEoVZshB │ 2018-12-27 16:21:00 │ 2019-01-09 06:52:30 │       5291555 │       5653873 │         362318 │    472 │
14. │ TMtq5VJwCJRLwuT4DD9fZ3kG7AbgbafMHH │ 2018-12-31 14:08:06 │ 2019-01-30 00:38:33 │       5403876 │       6236685 │         832809 │   5198 │
15. │ TVif6Avt3Q8FzcvQ3tTsziYEFran6D3Jvd │ 2019-01-03 07:47:57 │ 2019-02-03 12:57:21 │       5482439 │       6366345 │         883906 │    269 │
16. │ TRRGC2RvhFQP5RcDfPg91s6xok3PuP4gWD │ 2019-01-03 10:30:33 │ 2019-01-04 09:06:09 │       5485690 │       5512770 │          27080 │    621 │
17. │ TCdFuJ1EsyXUDBUtqb5hrLPqJZtrpNus3J │ 2019-01-04 02:54:45 │ 2019-01-21 08:31:24 │       5505353 │       5988546 │         483193 │    149 │
18. │ TQ7AaGYQmFjN9bip8B7o5Bjacp7BccADnS │ 2019-01-04 06:01:21 │ 2019-03-01 09:15:36 │       5509075 │       7109600 │        1600525 │    728 │
19. │ TUXB6xwmjDttGrJmkNTEotEVK8jStu8499 │ 2019-01-04 12:09:24 │ 2019-03-01 09:14:06 │       5516431 │       7109570 │        1593139 │   3743 │
20. │ TPkQCvenqF3Jc1q4U5s3sv6oEGBwSE1UHk │ 2019-01-04 12:53:21 │ 2019-01-13 11:07:48 │       5517310 │       5773740 │         256430 │    340 │
    └────────────────────────────────────┴─────────────────────┴─────────────────────┴───────────────┴───────────────┴────────────────┴────────┘

