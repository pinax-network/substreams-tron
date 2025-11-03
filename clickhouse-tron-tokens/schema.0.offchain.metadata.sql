CREATE TABLE IF NOT EXISTS metadata (
    contract                 String,
    decimals                 UInt8,
    name                     String,
    symbol                   String,
    last_update              DateTime('UTC') DEFAULT now(),

    -- indexes --
    INDEX idx_contract (contract) TYPE bloom_filter GRANULARITY 1,
    INDEX idx_name (name) TYPE bloom_filter GRANULARITY 1,
    INDEX idx_symbol (symbol) TYPE bloom_filter GRANULARITY 1,
    INDEX idx_decimals (decimals) TYPE minmax GRANULARITY 1
)
ENGINE = ReplacingMergeTree
ORDER BY ( contract );
