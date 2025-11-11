-- WETH Deposit/Withdrawal Logs --
CREATE TABLE IF NOT EXISTS weth_deposit AS TEMPLATE_LOG
COMMENT 'WETH Deposit events from logs';
ALTER TABLE weth_deposit
    -- event --
    ADD COLUMN IF NOT EXISTS dst        String,
    ADD COLUMN IF NOT EXISTS wad        UInt256,

    -- INDEXES --
    ADD INDEX IF NOT EXISTS idx_wad (wad) TYPE minmax GRANULARITY 1,

    -- PROJECTIONS --
    -- count() --
    ADD PROJECTION IF NOT EXISTS prj_dst_count ( SELECT dst, count() GROUP BY dst ),
    ADD PROJECTION IF NOT EXISTS prj_log_address_dst_count ( SELECT log_address, dst, count() GROUP BY log_address, dst ),

    -- minute --
    ADD PROJECTION IF NOT EXISTS prj_dst_by_minute ( SELECT dst, minute, count() GROUP BY dst, minute ),
    ADD PROJECTION IF NOT EXISTS prj_log_address_dst_by_minute ( SELECT log_address, dst, minute, count() GROUP BY log_address, dst, minute);


-- WETH Withdrawal Logs --
CREATE TABLE IF NOT EXISTS weth_withdrawal AS TEMPLATE_LOG
COMMENT 'WETH Withdrawal events from logs';
ALTER TABLE weth_withdrawal
    -- event --
    ADD COLUMN IF NOT EXISTS src        String,
    ADD COLUMN IF NOT EXISTS wad        UInt256,

    -- INDEXES --
    ADD INDEX IF NOT EXISTS idx_wad (wad) TYPE minmax GRANULARITY 1,

    -- PROJECTIONS --
    -- count() --
    ADD PROJECTION IF NOT EXISTS prj_src_count ( SELECT src, count() GROUP BY src ),
    ADD PROJECTION IF NOT EXISTS prj_log_address_src_count ( SELECT log_address, src, count() GROUP BY log_address, src ),
    -- minute --
    ADD PROJECTION IF NOT EXISTS prj_src_by_minute ( SELECT src, minute, count() GROUP BY src, minute ),
    ADD PROJECTION IF NOT EXISTS prj_log_address_src_by_minute ( SELECT log_address, src, minute, count() GROUP BY log_address, src, minute);
