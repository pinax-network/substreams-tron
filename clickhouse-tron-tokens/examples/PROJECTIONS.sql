-- 1) How much did we read/decompress?
SELECT read_rows, read_bytes, result_rows, result_bytes,
       memory_usage, query_duration_ms
FROM system.query_log
WHERE query_id = 'dee55d43-4858-4fb5-b6ee-a6dd717a9222'
  AND type = 'QueryFinish';

-- 2) Low-level counters (selected marks, rows filtered, etc.)
SELECT *
FROM system.query_thread_log
WHERE query_id = 'dee55d43-4858-4fb5-b6ee-a6dd717a9222';

-- 3) Which parts are using the projection vs base
SELECT
  table, name AS projection, part_name, rows, bytes_on_disk
FROM system.projection_parts
WHERE table = 'trc20_transfer';
-- status = 'active' means materialized and used. If many are not active, materialize them.

EXPLAIN indexes = 1, projections = 1
WITH hours AS (
    SELECT DISTINCT hour
    FROM trc20_transfer
    WHERE `from` IN ['TM1zzNDZD2DPASbKcgdVoTYhfmYgtfwx9R']
)
SELECT * FROM trc20_transfer
WHERE hour IN hours AND `from` IN ['TM1zzNDZD2DPASbKcgdVoTYhfmYgtfwx9R']
LIMIT 10;


EXPLAIN indexes = 1, projections = 1
WITH dates AS (
    SELECT DISTINCT date
    FROM trc20_transfer_agg
    WHERE account IN ['TM1zzNDZD2DPASbKcgdVoTYhfmYgtfwx9R']
)
SELECT * FROM trc20_transfer
WHERE toDate(date) IN dates AND from IN ['TM1zzNDZD2DPASbKcgdVoTYhfmYgtfwx9R']
LIMIT 10;

-- 4) Check ongoing or past mutations on the table
SELECT
    mutation_id,
    command,
    parts_to_do,
    is_done
FROM system.mutations
WHERE table = 'trc20_transfer'
ORDER BY create_time DESC;
