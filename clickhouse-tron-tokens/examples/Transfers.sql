-- basic filter by 'from' address --
EXPLAIN indexes = 1, projections = 1
SELECT *
FROM trc20_transfer
WHERE from IN ['TCfeM1VFrBmCkL92pcrtWW61uJQYb91uwM']

-- filter by 'from' address using minute projection (PROJECTION) --
EXPLAIN indexes = 1, projections = 1
WITH minutes AS (
    SELECT toRelativeMinuteNum(timestamp) AS minute
    FROM trc20_transfer
    WHERE from IN ['TCfeM1VFrBmCkL92pcrtWW61uJQYb91uwM']
    GROUP BY minute
)
SELECT *
FROM trc20_transfer
WHERE from IN ['TCfeM1VFrBmCkL92pcrtWW61uJQYb91uwM']
AND toRelativeMinuteNum(timestamp) IN minutes
LIMIT 10;

-- filter by 'from' address using minute projection --
EXPLAIN indexes = 1, projections = 1
WITH minutes AS (
    SELECT minute
    FROM trc20_transfer_by_from
    WHERE from IN ['TCfeM1VFrBmCkL92pcrtWW61uJQYb91uwM']
    GROUP BY minute
)
SELECT *
FROM trc20_transfer
WHERE from IN ['TCfeM1VFrBmCkL92pcrtWW61uJQYb91uwM']
AND toRelativeMinuteNum(timestamp) IN minutes


EXPLAIN indexes = 1, projections = 1
SELECT toRelativeMinuteNum(timestamp) AS minute
FROM trc20_transfer
WHERE from IN ['TCfeM1VFrBmCkL92pcrtWW61uJQYb91uwM']
GROUP BY minute


EXPLAIN indexes = 1, projections = 1
SELECT minute
FROM trc20_transfer_by_from
WHERE from IN ['TCfeM1VFrBmCkL92pcrtWW61uJQYb91uwM']
GROUP BY minute