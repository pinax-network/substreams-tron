-- JustSwap TokenPurchase --
CREATE TABLE IF NOT EXISTS justswap_token_purchase AS TEMPLATE_LOG
COMMENT 'JustSwap V1 TokenPurchase events';
ALTER TABLE justswap_token_purchase
    -- swap event information --
    ADD COLUMN IF NOT EXISTS buyer              String COMMENT 'buyer wallet address',
    ADD COLUMN IF NOT EXISTS trx_sold           UInt256 COMMENT 'Amount of TRX sold',
    ADD COLUMN IF NOT EXISTS tokens_bought      UInt256 COMMENT 'Amount of tokens bought',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_buyer (buyer) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_trx_sold (trx_sold) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_tokens_bought (tokens_bought) TYPE minmax GRANULARITY 1;

-- JustSwap TrxPurchase --
CREATE TABLE IF NOT EXISTS justswap_trx_purchase AS TEMPLATE_LOG
COMMENT 'JustSwap V1 TrxPurchase events';
ALTER TABLE justswap_trx_purchase
    -- swap event information --
    ADD COLUMN IF NOT EXISTS buyer              String COMMENT 'buyer wallet address',
    ADD COLUMN IF NOT EXISTS tokens_sold        UInt256 COMMENT 'Amount of tokens sold',
    ADD COLUMN IF NOT EXISTS trx_bought         UInt256 COMMENT 'Amount of TRX bought',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_buyer (buyer) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_tokens_sold (tokens_sold) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_trx_bought (trx_bought) TYPE minmax GRANULARITY 1;

-- JustSwap AddLiquidity --
CREATE TABLE IF NOT EXISTS justswap_add_liquidity AS TEMPLATE_LOG
COMMENT 'JustSwap V1 AddLiquidity events';
ALTER TABLE justswap_add_liquidity
    -- event information --
    ADD COLUMN IF NOT EXISTS provider           String COMMENT 'Liquidity provider address',
    ADD COLUMN IF NOT EXISTS trx_amount         UInt256 COMMENT 'Amount of TRX added',
    ADD COLUMN IF NOT EXISTS token_amount       UInt256 COMMENT 'Amount of tokens added',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_provider (provider) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_trx_amount (trx_amount) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token_amount (token_amount) TYPE minmax GRANULARITY 1;

-- JustSwap RemoveLiquidity --
CREATE TABLE IF NOT EXISTS justswap_remove_liquidity AS TEMPLATE_LOG
COMMENT 'JustSwap V1 RemoveLiquidity events';
ALTER TABLE justswap_remove_liquidity
    -- event information --
    ADD COLUMN IF NOT EXISTS provider           String COMMENT 'Liquidity provider address',
    ADD COLUMN IF NOT EXISTS trx_amount         UInt256 COMMENT 'Amount of TRX removed',
    ADD COLUMN IF NOT EXISTS token_amount       UInt256 COMMENT 'Amount of tokens removed',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_provider (provider) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_trx_amount (trx_amount) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token_amount (token_amount) TYPE minmax GRANULARITY 1;

-- JustSwap Snapshot --
CREATE TABLE IF NOT EXISTS justswap_snapshot AS TEMPLATE_LOG
COMMENT 'JustSwap V1 Snapshot events';
ALTER TABLE justswap_snapshot
    -- event information --
    ADD COLUMN IF NOT EXISTS operator           String COMMENT 'Snapshot operator address',
    ADD COLUMN IF NOT EXISTS trx_balance        UInt256 COMMENT 'TRX balance at snapshot',
    ADD COLUMN IF NOT EXISTS token_balance      UInt256 COMMENT 'Token balance at snapshot',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_operator (operator) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_trx_balance (trx_balance) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token_balance (token_balance) TYPE minmax GRANULARITY 1;

-- JustSwap NewExchange --
CREATE TABLE IF NOT EXISTS justswap_new_exchange AS TEMPLATE_LOG
COMMENT 'JustSwap V1 NewExchange events';
ALTER TABLE justswap_new_exchange
    -- event information --
    ADD COLUMN IF NOT EXISTS exchange           String COMMENT 'Exchange contract address',
    ADD COLUMN IF NOT EXISTS token              String COMMENT 'Token contract address',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_exchange (exchange) TYPE bloom_filter(0.005) GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token (token) TYPE bloom_filter(0.005) GRANULARITY 1;
