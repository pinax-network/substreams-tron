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
) SELECT * FROM transfers
WHERE count >= 500
ORDER BY block_num_diff ASC
LIMIT 50;


    ┌─log_address────────────────────────┬───────min_timestamp─┬───────max_timestamp─┬─min_block_num─┬─max_block_num─┬─block_num_diff─┬──count─┐

10. │ TY5NJKhJFkipYDokTAgo8TtzTwpicXNoCQ │ 2023-05-09 14:37:57 │ 2023-05-09 15:03:42 │      51009736 │      51010251 │            515 │   6156 │
11. │ TEw6v7UVQRwSi9FHZaKaYDxR8UTi2usuaJ │ 2023-05-09 14:33:18 │ 2023-05-09 15:00:06 │      51009643 │      51010179 │            536 │   6156 │
12. │ TVifHwfCrNnzj1uiRgDoxMitnq4kedPbYU │ 2023-05-09 14:38:12 │ 2023-05-09 15:09:15 │      51009741 │      51010362 │            621 │   6156 │
13. │ TJZevS6H6ZBUj5LTtTzgw8teoCz9pfKYsN │ 2023-05-09 14:38:24 │ 2023-05-09 15:13:39 │      51009745 │      51010450 │            705 │   6139 │
14. │ TZJK5yXVwzz5JEY7wAFNRpiJaC4F4u4925 │ 2023-06-06 03:26:45 │ 2023-06-06 04:05:45 │      51800457 │      51801237 │            780 │  19398 │
15. │ TQJDgbHd23V6SAeuADbHBFENBFcpJ17ePp │ 2023-05-12 07:02:12 │ 2023-05-12 07:43:12 │      51086890 │      51087680 │            790 │   8502 │
16. │ TJSmP3gXUsSYuKVmxJHBtaQNdshABP6B4J │ 2023-12-01 11:51:48 │ 2023-12-01 12:35:24 │      56932899 │      56933769 │            870 │   3348 │
17. │ TMuhws8tPneszmnzXBJb1NG7TK769WZp2h │ 2023-05-25 12:48:27 │ 2023-05-25 13:38:03 │      51467927 │      51468919 │            992 │    793 │
18. │ TT2dLnmJXW78DXh3BBkwknVnmRPXmqKbYi │ 2023-05-12 07:02:24 │ 2023-05-12 07:56:21 │      51086894 │      51087933 │           1039 │   8502 │


    ┌─log_address────────────────────────┬───────min_timestamp─┬───────max_timestamp─┬─min_block_num─┬─max_block_num─┬─block_num_diff─┬──count─┐
43. │ TWz4fZU2p7eZvhV3zjLJMvJXm1AQwboRLA │ 2021-09-29 10:51:00 │ 2021-09-29 14:35:51 │      34132736 │      34137228 │           4492 │    840 │
