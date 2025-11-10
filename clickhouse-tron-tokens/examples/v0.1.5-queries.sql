-- v0.1.5 (intersect 2 filters)
EXPLAIN indexes = 1, projections = 1
SELECT DISTINCT minute
FROM trc20_transfer_from_minutes
WHERE `from` = 'TRGxi9hLeNZgponDsHgLvLwDQoq7U5VPTF'
INTERSECT DISTINCT
SELECT DISTINCT minute
FROM trc20_transfer_to_minutes
WHERE `to` = 'TB4S2pvyX8uQsBPrTDWYCuSDfYSg6tMJm7';

-- v0.1.4 (intersect 2 filters)
EXPLAIN indexes = 1, projections = 1
SELECT minute
FROM trc20_transfer_minutes
WHERE `from` = 'TRGxi9hLeNZgponDsHgLvLwDQoq7U5VPTF' AND `to` = 'TB4S2pvyX8uQsBPrTDWYCuSDfYSg6tMJm7'
GROUP BY minute;

-- v0.1.5 (intersect 3 filters)
EXPLAIN indexes = 1, projections = 1
SELECT minute
FROM trc20_transfer_from_minutes
WHERE `from` = 'TCb1jjfKYZkNWqNn2XYSDmYHCroWSQ8MJg'
INTERSECT DISTINCT
SELECT minute
FROM trc20_transfer_to_minutes
WHERE `to` = 'TPGraFHWoKJx7Qmbp1MpXwoxQWE9fB4mnn'
INTERSECT DISTINCT
SELECT minute
FROM trc20_transfer_log_address_minutes
WHERE log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t';

-- v0.1.4 (intersect 3 filters)
EXPLAIN indexes = 1, projections = 1
SELECT minute
FROM trc20_transfer_minutes
WHERE `from` = 'TCb1jjfKYZkNWqNn2XYSDmYHCroWSQ8MJg' AND `to` = 'TPGraFHWoKJx7Qmbp1MpXwoxQWE9fB4mnn' AND log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'
GROUP BY minute;

-- v0.1.5
EXPLAIN indexes = 1, projections = 1
SELECT toStartOfTenMinutes(minute) AS t
FROM trc20_transfer_log_address_minutes
WHERE log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'
GROUP BY t;

-- v0.1.4
EXPLAIN indexes = 1, projections = 1
SELECT toStartOfTenMinutes(minute) AS t
FROM trc20_transfer_minutes
WHERE log_address = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t'
GROUP BY t;