CREATE TABLE IF NOT EXISTS trc20_balances_rpc (
    contract                 String,
    account                  String,
    balance_hex              String,
    -- DEFAULT balance is required to allow filtering by >0 balance
    balance                  UInt256 DEFAULT abi_hex_to_uint256(balance_hex),
    last_update              DateTime('UTC') DEFAULT now(),
    error                    String DEFAULT '',

    -- indexes --
    INDEX idx_contract_account (contract, account) TYPE bloom_filter GRANULARITY 1,
    INDEX idx_last_update (last_update) TYPE minmax GRANULARITY 1,
    INDEX idx_balance (balance) TYPE minmax GRANULARITY 1,
    INDEX idx_error (error) TYPE bloom_filter GRANULARITY 1
)
ENGINE = ReplacingMergeTree(last_update)
ORDER BY ( contract, account );

-- VIEW for easier querying
CREATE OR REPLACE VIEW trc20_balances AS
SELECT
    contract,
    account,
    balance,
    last_update
FROM trc20_balances_rpc
WHERE error = '';