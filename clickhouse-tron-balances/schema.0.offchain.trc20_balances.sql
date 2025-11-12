CREATE TABLE IF NOT EXISTS trc20_balances_rpc (
    -- block --
    block_num                   UInt32,
    block_hash                  String,
    timestamp                   DateTime('UTC'),
    minute                      UInt32 DEFAULT toRelativeMinuteNum(timestamp),

    -- balance --
    contract                    LowCardinality(String),
    account                     String,
    balance_hex                 String,

    -- DEFAULT balance is required to allow filtering by >0 balance
    balance                     UInt256 DEFAULT abi_hex_to_uint256_or_zero(balance_hex),
    last_update                 DateTime('UTC') DEFAULT now(),
    error                       LowCardinality(String) DEFAULT '',

    -- Optional: keep a quick boolean to avoid string compares
    is_ok                       UInt8 DEFAULT (error = ''),

    -- PROJECTIONS --
    -- count() --
    ADD PROJECTION IF NOT EXISTS prj_contract_count ( SELECT contract, count() GROUP BY contract ),
    ADD PROJECTION IF NOT EXISTS prj_account_count ( SELECT account, count() GROUP BY account ),

    -- minute --
    ADD PROJECTION IF NOT EXISTS prj_contract ( SELECT contract, minute, count() GROUP BY contract, minute ),
    ADD PROJECTION IF NOT EXISTS prj_account_by_minute ( SELECT account, minute, count() GROUP BY account, minute ),

)
ENGINE = MergeTree
ORDER BY (
    minute, timestamp, block_num,
    contract, account
);

-- Table to keep the latest TRC20 balances per (contract, account) --
CREATE TABLE IF NOT EXISTS trc20_balances (
    -- block --
    block_num                   UInt32,
    block_hash                  String,
    timestamp                   DateTime('UTC'),
    minute                      UInt32 COMMENT 'toRelativeMinuteNum(timestamp)',

    -- balance --
    contract                    LowCardinality(String),
    account                     String,
    balance                     UInt256
)
ENGINE = ReplacingMergeTree(block_num)
ORDER BY (
    contract, account
);

-- Table to keep the latest TRC20 balances per (contract, account) with non-zero balances only --
CREATE MATERIALIZED VIEW IF NOT EXISTS mv_trc20_balances
TO trc20_balances
AS
SELECT
    block_num,
    block_hash,
    timestamp,
    minute,
    contract,
    account,
    balance
FROM trc20_balances_rpc
WHERE is_ok = 1;
