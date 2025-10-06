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
