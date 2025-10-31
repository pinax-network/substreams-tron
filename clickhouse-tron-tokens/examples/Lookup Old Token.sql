WITH transfers AS (
    SELECT
        log_address,
        min(timestamp) as min_timestamp,
        max(timestamp) as max_timestamp,
        min(block_num) as min_block_num,
        max(block_num) as max_block_num,
        max(block_num) - min(block_num) as block_num_diff,
        count() as count
    FROM trc20_transfer
    GROUP BY log_address
    ORDER BY min(block_num) ASC
) SELECT * FROM transfers
WHERE YEAR(max_timestamp) <= 2019
AND count >= 100
LIMIT 20;
