-- SunPump TokenPurchased --
CREATE TABLE IF NOT EXISTS sunpump_token_purchased AS TEMPLATE_LOG
COMMENT 'SunPump TokenPurchased and TokenSold swap events';
ALTER TABLE sunpump_token_purchased
    -- swap event information --
    ADD COLUMN IF NOT EXISTS buyer                  String COMMENT 'User wallet address',
    ADD COLUMN IF NOT EXISTS trx_amount             UInt256 COMMENT 'Amount of input tokens swapped',
    ADD COLUMN IF NOT EXISTS token                  LowCardinality(String) COMMENT 'Token contract address',
    ADD COLUMN IF NOT EXISTS token_amount           UInt256 COMMENT 'Amount of output tokens received',
    ADD COLUMN IF NOT EXISTS fee                    UInt256 COMMENT 'Swap fee amount',
    ADD COLUMN IF NOT EXISTS token_reserve          UInt256 COMMENT 'Token reserve after swap (only for purchases)',

    -- TokenCreate --
    ADD COLUMN IF NOT EXISTS factory                String COMMENT 'Factory contract address',
    ADD COLUMN IF NOT EXISTS creator                String COMMENT 'Token creator address',
    ADD COLUMN IF NOT EXISTS token_index            UInt256 COMMENT 'Token index',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_buyer (buyer) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_trx_amount (trx_amount) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token (token) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token_amount (token_amount) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_fee (fee) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token_reserve (token_reserve) TYPE minmax GRANULARITY 1,

    -- indexes (TokenCreate) --
    ADD INDEX IF NOT EXISTS idx_factory (factory) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_creator (creator) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token_index (token_index) TYPE minmax GRANULARITY 1;

-- SunPump TokenSold --
CREATE TABLE IF NOT EXISTS sunpump_token_sold AS TEMPLATE_LOG
COMMENT 'SunPump TokenPurchased and TokenSold swap events';
ALTER TABLE sunpump_token_sold
    -- swap event information --
    ADD COLUMN IF NOT EXISTS seller             String COMMENT 'User wallet address',
    ADD COLUMN IF NOT EXISTS token              LowCardinality(String) COMMENT 'Token contract address',
    ADD COLUMN IF NOT EXISTS token_amount       UInt256 COMMENT 'Amount of output tokens received',
    ADD COLUMN IF NOT EXISTS trx_amount         UInt256 COMMENT 'Amount of input tokens swapped',
    ADD COLUMN IF NOT EXISTS fee                UInt256 COMMENT 'Swap fee amount',

    -- TokenCreate --
    ADD COLUMN IF NOT EXISTS factory                String COMMENT 'Factory contract address',
    ADD COLUMN IF NOT EXISTS creator                String COMMENT 'Token creator address',
    ADD COLUMN IF NOT EXISTS token_index            UInt256 COMMENT 'Token index',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_seller (seller) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token (token) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token_amount (token_amount) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_trx_amount (trx_amount) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_fee (fee) TYPE minmax GRANULARITY 1,

    -- indexes (TokenCreate) --
    ADD INDEX IF NOT EXISTS idx_factory (factory) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_creator (creator) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token_index (token_index) TYPE minmax GRANULARITY 1;

-- SunPump LaunchPending --
CREATE TABLE IF NOT EXISTS sunpump_launch_pending AS TEMPLATE_LOG
COMMENT 'SunPump LaunchPending events';
ALTER TABLE sunpump_launch_pending
    -- event information --
    ADD COLUMN IF NOT EXISTS token              LowCardinality(String) COMMENT 'Token contract address',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_token (token) TYPE bloom_filter GRANULARITY 1;

-- SunPump LauncherChanged --
CREATE TABLE IF NOT EXISTS sunpump_launcher_changed AS TEMPLATE_LOG
COMMENT 'SunPump LauncherChanged events';
ALTER TABLE sunpump_launcher_changed
    -- event information --
    ADD COLUMN IF NOT EXISTS old_launcher       String COMMENT 'Old launcher address',
    ADD COLUMN IF NOT EXISTS new_launcher       String COMMENT 'New launcher address',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_old_launcher (old_launcher) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_new_launcher (new_launcher) TYPE bloom_filter GRANULARITY 1;

-- SunPump MinTxFeeSet --
CREATE TABLE IF NOT EXISTS sunpump_min_tx_fee_set AS TEMPLATE_LOG
COMMENT 'SunPump MinTxFeeSet events';
ALTER TABLE sunpump_min_tx_fee_set
    -- event information --
    ADD COLUMN IF NOT EXISTS old_fee            UInt256 COMMENT 'Old minimum transaction fee',
    ADD COLUMN IF NOT EXISTS new_fee            UInt256 COMMENT 'New minimum transaction fee',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_old_fee (old_fee) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_new_fee (new_fee) TYPE minmax GRANULARITY 1;

-- SunPump MintFeeSet --
CREATE TABLE IF NOT EXISTS sunpump_mint_fee_set AS TEMPLATE_LOG
COMMENT 'SunPump MintFeeSet events';
ALTER TABLE sunpump_mint_fee_set
    -- event information --
    ADD COLUMN IF NOT EXISTS old_fee            UInt256 COMMENT 'Old mint fee',
    ADD COLUMN IF NOT EXISTS new_fee            UInt256 COMMENT 'New mint fee',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_old_fee (old_fee) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_new_fee (new_fee) TYPE minmax GRANULARITY 1;

-- SunPump OperatorChanged --
CREATE TABLE IF NOT EXISTS sunpump_operator_changed AS TEMPLATE_LOG
COMMENT 'SunPump OperatorChanged events';
ALTER TABLE sunpump_operator_changed
    -- event information --
    ADD COLUMN IF NOT EXISTS old_operator       String COMMENT 'Old operator address',
    ADD COLUMN IF NOT EXISTS new_operator       String COMMENT 'New operator address',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_old_operator (old_operator) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_new_operator (new_operator) TYPE bloom_filter GRANULARITY 1;

-- SunPump OwnerChanged --
CREATE TABLE IF NOT EXISTS sunpump_owner_changed AS TEMPLATE_LOG
COMMENT 'SunPump OwnerChanged events';
ALTER TABLE sunpump_owner_changed
    -- event information --
    ADD COLUMN IF NOT EXISTS old_owner          String COMMENT 'Old owner address',
    ADD COLUMN IF NOT EXISTS new_owner          String COMMENT 'New owner address',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_old_owner (old_owner) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_new_owner (new_owner) TYPE bloom_filter GRANULARITY 1;

-- SunPump PendingOwnerSet --
CREATE TABLE IF NOT EXISTS sunpump_pending_owner_set AS TEMPLATE_LOG
COMMENT 'SunPump PendingOwnerSet events';
ALTER TABLE sunpump_pending_owner_set
    -- event information --
    ADD COLUMN IF NOT EXISTS old_pending_owner  String COMMENT 'Old pending owner address',
    ADD COLUMN IF NOT EXISTS new_pending_owner  String COMMENT 'New pending owner address',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_old_pending_owner (old_pending_owner) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_new_pending_owner (new_pending_owner) TYPE bloom_filter GRANULARITY 1;

-- SunPump PurchaseFeeSet --
CREATE TABLE IF NOT EXISTS sunpump_purchase_fee_set AS TEMPLATE_LOG
COMMENT 'SunPump PurchaseFeeSet events';
ALTER TABLE sunpump_purchase_fee_set
    -- event information --
    ADD COLUMN IF NOT EXISTS old_fee            UInt256 COMMENT 'Old purchase fee',
    ADD COLUMN IF NOT EXISTS new_fee            UInt256 COMMENT 'New purchase fee',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_old_fee (old_fee) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_new_fee (new_fee) TYPE minmax GRANULARITY 1;

-- SunPump SaleFeeSet --
CREATE TABLE IF NOT EXISTS sunpump_sale_fee_set AS TEMPLATE_LOG
COMMENT 'SunPump SaleFeeSet events';
ALTER TABLE sunpump_sale_fee_set
    -- event information --
    ADD COLUMN IF NOT EXISTS old_fee            UInt256 COMMENT 'Old sale fee',
    ADD COLUMN IF NOT EXISTS new_fee            UInt256 COMMENT 'New sale fee',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_old_fee (old_fee) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_new_fee (new_fee) TYPE minmax GRANULARITY 1;

-- SunPump TokenCreate --
CREATE TABLE IF NOT EXISTS sunpump_token_create AS TEMPLATE_LOG
COMMENT 'SunPump TokenCreate events';
ALTER TABLE sunpump_token_create
    -- event information --
    ADD COLUMN IF NOT EXISTS token_address      LowCardinality(String) COMMENT 'Token contract address',
    ADD COLUMN IF NOT EXISTS token_index        UInt256 COMMENT 'Token index',
    ADD COLUMN IF NOT EXISTS creator            String COMMENT 'Creator address',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_token_address (token_address) TYPE bloom_filter GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_token_index (token_index) TYPE minmax GRANULARITY 1,
    ADD INDEX IF NOT EXISTS idx_creator (creator) TYPE bloom_filter GRANULARITY 1;

-- SunPump TokenLaunched --
CREATE TABLE IF NOT EXISTS sunpump_token_launched AS TEMPLATE_LOG
COMMENT 'SunPump TokenLaunched events';
ALTER TABLE sunpump_token_launched
    -- event information --
    ADD COLUMN IF NOT EXISTS token              LowCardinality(String) COMMENT 'Token contract address',

    -- indexes --
    ADD INDEX IF NOT EXISTS idx_token (token) TYPE bloom_filter GRANULARITY 1;
