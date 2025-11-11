-- count --
SELECT
    from,
    count()
FROM trc20_transfer
GROUP BY from
ORDER BY count() DESC
LIMIT 10

-- minute filter --
EXPLAIN indexes =1, projections =1
SELECT minute
FROM trc20_transfer
WHERE `from` = 'TYASr5UV6HEcXatwdFQfmLVUqQQQMUxHLS'
GROUP BY minute

-- minute filter + transfers --
EXPLAIN indexes =1, projections =1
WITH minutes AS (
    SELECT minute
    FROM trc20_transfer
    WHERE `from` = 'TYASr5UV6HEcXatwdFQfmLVUqQQQMUxHLS'
    GROUP BY minute
)
SELECT * FROM trc20_transfer
WHERE minute IN minutes
LIMIT 10