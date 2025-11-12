CREATE TABLE IF NOT EXISTS trc20_balances_rpc (
    -- block --
    block_num                   UInt32 DEFAULT 0,
    block_hash                  String DEFAULT '',
    timestamp                   DateTime('UTC') DEFAULT now(),
    minute                      UInt32 DEFAULT toRelativeMinuteNum(timestamp),

    -- balance --
    contract                    LowCardinality(String),
    account                     String,
    balance_hex                 String,
    balance                     UInt256 DEFAULT abi_hex_to_uint256_or_zero(balance_hex),

    -- error handling --
    last_update                 DateTime('UTC') DEFAULT now(),
    error                       LowCardinality(String) DEFAULT '',
    is_ok                       UInt8 DEFAULT (error = ''), -- 1 if no error, 0 otherwise

    -- INDEXES --
    INDEX idx_balance           (balance) TYPE minmax GRANULARITY 1,

    -- PROJECTIONS --
    -- count() --
    PROJECTION prj_block_hash_count ( SELECT block_hash, count() GROUP BY block_hash ),
    PROJECTION prj_contract_count ( SELECT contract, count() GROUP BY contract ),
    PROJECTION prj_account_count ( SELECT account, count() GROUP BY account ),
    PROJECTION prj_contract_account_count ( SELECT contract, account, count() GROUP BY contract, account )
)
ENGINE = MergeTree
ORDER BY (
    contract, account, block_num
);

-- Latest Balances
CREATE TABLE IF NOT EXISTS trc20_balances (
    -- block --
    block_num                   UInt32,
    block_hash                  String,
    timestamp                   DateTime('UTC'),
    minute                      UInt32,

    -- token metadata --
    contract                    String,
    account                     String,
    balance                     UInt256,

    -- INDEX --
    INDEX idx_balance           (balance) TYPE minmax GRANULARITY 1,

    -- PROJECTIONS --
    PROJECTION prj_account_contract ( SELECT * ORDER BY contract, account )
)
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (
    contract, account
)
SETTINGS deduplicate_merge_projection_mode = 'rebuild';

-- Table to keep the latest TRC20 balances per (contract, account) with non-zero balances only --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_balances
TO trc20_balances
AS
SELECT
    -- block --
    block_num,
    block_hash,
    timestamp,
    minute,

    -- balance --
    contract,
    account,
    balance
FROM trc20_balances_rpc
WHERE is_ok = 1;
