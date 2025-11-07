CREATE TABLE IF NOT EXISTS trc20_balances_rpc (
    contract                 LowCardinality(String),
    account                  String,
    balance_hex              String,
    -- DEFAULT balance is required to allow filtering by >0 balance
    balance                  UInt256 DEFAULT abi_hex_to_uint256_or_zero(balance_hex),
    last_update              DateTime('UTC') DEFAULT now(),
    error                    LowCardinality(String) DEFAULT '',

    -- Optional: keep a quick boolean to avoid string compares
    is_ok           UInt8 DEFAULT (error = ''),

    -- indexes --
    INDEX idx_contract (contract) TYPE bloom_filter GRANULARITY 4,
    INDEX idx_account (account) TYPE bloom_filter GRANULARITY 4,
    INDEX idx_last_update (last_update) TYPE minmax GRANULARITY 1,
    INDEX idx_balance (balance) TYPE minmax GRANULARITY 1,
    INDEX idx_error (error) TYPE set(10) GRANULARITY 1,
    INDEX idx_is_ok (is_ok) TYPE set(2) GRANULARITY 1,
)
ENGINE = ReplacingMergeTree(last_update)
ORDER BY ( account, contract );

ALTER TABLE trc20_balances_rpc
    MODIFY SETTING deduplicate_merge_projection_mode = 'rebuild';

ALTER TABLE trc20_balances_rpc ADD PROJECTION IF NOT EXISTS prj_contract_account ( SELECT * ORDER BY ( contract, account ) );

-- VIEW for easier querying
CREATE OR REPLACE VIEW trc20_balances AS
SELECT
    contract,
    account,
    balance,
    last_update
FROM trc20_balances_rpc
WHERE is_ok = 1;