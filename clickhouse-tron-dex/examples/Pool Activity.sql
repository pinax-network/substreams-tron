SELECT
    factory,
    protocol,
    count()
FROM pool_activity_summary
GROUP BY
    factory,
    protocol
ORDER BY count() DESC;