-- Store signed balance changes
CREATE TABLE IF NOT EXISTS balance_deltas (
    -- block
    block_num      UInt32,
    timestamp      DateTime(0, 'UTC'),

    -- balance
    contract       LowCardinality(String),
    account        String,

    -- signed change
    amount_delta   Int256,

    -- (optional) provenance if you ever need it
    tx_index       UInt32,
    log_index      UInt32,

    INDEX idx_contract (contract) TYPE bloom_filter(0.005) GRANULARITY 1,
    INDEX idx_account  (account)  TYPE bloom_filter(0.005) GRANULARITY 1,
    INDEX idx_block    (block_num) TYPE minmax GRANULARITY 1
)
ENGINE = SummingMergeTree(amount_delta)
ORDER BY (contract, account, block_num, timestamp, tx_index, log_index);

-- +credits: to-account receives amount
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_to_deltas
TO balance_deltas
AS
SELECT
    log_address                                  AS contract,
    `to`                                         AS account,
    CAST(amount AS Int256)                       AS amount_delta,
    block_num, timestamp, tx_index, log_index
FROM trc20_transfer;

-- -debits: from-account sends amount (negative delta)
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_from_deltas
TO balance_deltas
AS
SELECT
    log_address                                  AS contract,
    `from`                                       AS account,
    -CAST(amount AS Int256)                      AS amount_delta,
    block_num, timestamp, tx_index, log_index
FROM trc20_transfer;

CREATE OR REPLACE VIEW balances AS
SELECT
    max(block_num) AS block_num,
    max(timestamp) AS timestamp,
    contract,
    account,
    sum(amount_delta) AS balance
FROM balance_deltas
GROUP BY contract, account;