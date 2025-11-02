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
WHERE count >= 100
ORDER BY block_num_diff ASC
LIMIT 50;

    ┌─log_address────────────────────────┬───────min_timestamp─┬───────max_timestamp─┬─min_block_num─┬─max_block_num─┬─block_num_diff─┬──count─┐
 1. │ TRRGC2RvhFQP5RcDfPg91s6xok3PuP4gWD │ 2019-01-03 10:30:33 │ 2019-01-04 09:06:09 │       5485690 │       5512770 │          27080 │    621 │
 2. │ TUXB6xwmjDttGrJmkNTEotEVK8jStu8499 │ 2019-01-04 12:09:24 │ 2019-01-07 09:06:33 │       5516431 │       5599012 │          82581 │   2768 │
 3. │ TBopmnF7nMfShsHEZN6HDwuC4DfEbyuira │ 2019-01-02 06:18:03 │ 2019-01-07 13:43:27 │       5451883 │       5604545 │         152662 │  17481 │
 4. │ TLvDJcvKJDi3QuHgFbJC6SeTj3UacmtQU3 │ 2018-12-30 14:14:12 │ 2019-01-07 14:14:15 │       5375271 │       5605160 │         229889 │   2520 │
 5. │ TQuCYa3yi11s24VyR2Ye7XcWDG1MUJEbJq │ 2018-12-28 19:25:33 │ 2019-01-07 14:42:48 │       5323967 │       5605730 │         281763 │   6266 │
 6. │ TYPHiHUiPBPCNvqBpzy1f7bdqrZ5r8e1K7 │ 2018-12-27 16:50:15 │ 2019-01-07 12:33:06 │       5292139 │       5603140 │         311001 │   1530 │
 7. │ TYe6uNj7jxkwy28yXeLPs6KDLZCuUjXvgd │ 2018-12-27 18:11:51 │ 2019-01-07 14:33:27 │       5293763 │       5605543 │         311780 │   5888 │
 8. │ TBXVmYApySCRgqPfAYu9ors4dA7URQ2aET │ 2018-12-27 17:33:18 │ 2019-01-07 14:44:06 │       5292998 │       5605756 │         312758 │ 970371 │
 9. │ TLCiRv2qn9tP3x59B3jtxuonyQzUHwNyUq │ 2018-12-27 16:21:12 │ 2019-01-07 13:37:00 │       5291559 │       5604416 │         312857 │    904 │
10. │ TSkG9SSKdWV5QBuTPN6udi48rym5iPpLof │ 2018-12-27 16:58:42 │ 2019-01-07 14:30:00 │       5292307 │       5605474 │         313167 │   1734 │
11. │ TUh2Gkq1ZkQyZyfc2KZ9JQsMavWaY3Cdma │ 2018-12-27 16:30:09 │ 2019-01-07 14:06:42 │       5291738 │       5605009 │         313271 │   1342 │
12. │ TL175uyihLqQD656aFx3uhHYe1tyGkmXaW │ 2018-12-27 16:30:09 │ 2019-01-07 14:32:06 │       5291738 │       5605516 │         313778 │  30963 │
13. │ TNq5PbSssK5XfmSYU4Aox4XkgTdpDoEDiY │ 2018-12-27 16:23:30 │ 2019-01-07 14:30:30 │       5291605 │       5605484 │         313879 │   2645 │
14. │ TVeQmdceGXgFDSgfqqfHSSfxz4ucSmGjJA │ 2018-12-27 16:25:33 │ 2019-01-07 14:34:45 │       5291646 │       5605569 │         313923 │    761 │
15. │ TAuXsThKmMYZWJJwfkGipPNjGFvPyrjNnZ │ 2018-12-27 16:24:33 │ 2019-01-07 14:41:57 │       5291626 │       5605713 │         314087 │   3624 │
16. │ TNbYoP22d74RWy4ETssHsXYFrnmmbQ2fvt │ 2018-12-27 16:26:06 │ 2019-01-07 14:43:33 │       5291657 │       5605745 │         314088 │    852 │
17. │ TBAo7PNyKo94YWUq1Cs2LBFxkhTphnAE4T │ 2018-12-27 16:25:51 │ 2019-01-07 14:43:24 │       5291652 │       5605742 │         314090 │  15190 │
18. │ TMWkPhsb1dnkAVNy8ej53KrFNGWy9BJrfu │ 2018-12-27 16:22:51 │ 2019-01-07 14:42:18 │       5291592 │       5605720 │         314128 │  15893 │
19. │ TQY2hQDXuNVB1s1b16PP9K8gS3gi5RmwFj │ 2018-12-27 16:24:03 │ 2019-01-07 14:44:00 │       5291616 │       5605754 │         314138 │  23857 │
20. │ TNisVGhbxrJiEHyYUMPxRzgytUtGM7vssZ │ 2018-12-27 16:21:00 │ 2019-01-07 14:42:06 │       5291555 │       5605716 │         314161 │  23882 │
21. │ TYbSzw3PqBWohc4DdyzFDJMd1hWeNN6FkB │ 2018-12-27 16:22:09 │ 2019-01-07 14:43:33 │       5291578 │       5605745 │         314167 │  12383 │
22. │ TWGZ7HnAhZkvxiT89vCBSd6Pzwin5vt3ZA │ 2018-12-27 16:21:09 │ 2019-01-07 14:43:06 │       5291558 │       5605736 │         314178 │ 195600 │
23. │ TCN77KWWyUyi2A4Cu7vrh5dnmRyvUuME1E │ 2018-12-27 16:21:00 │ 2019-01-07 14:44:03 │       5291555 │       5605755 │         314200 │ 128013 │
24. │ THvZvKPLHKLJhEFYKiyqj6j8G8nGgfg7ur │ 2018-12-27 16:21:00 │ 2019-01-07 14:44:06 │       5291555 │       5605756 │         314201 │ 819446 │
    └────────────────────────────────────┴─────────────────────┴─────────────────────┴───────────────┴───────────────┴────────────────┴────────┘

