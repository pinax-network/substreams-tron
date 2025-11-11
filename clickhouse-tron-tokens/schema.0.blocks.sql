CREATE TABLE IF NOT EXISTS blocks (
    block_num                   UInt32,
    block_hash                  String,
    timestamp                   DateTime(0, 'UTC'),
    minute                      UInt32 COMMENT 'toRelativeMinuteNum(timestamp)',

    -- PROJECTIONS --
    PROJECTION prj_block_hash ( SELECT * ORDER BY block_hash )
)
ENGINE = MergeTree
ORDER BY (
    minute, timestamp, block_num
)
COMMENT 'TRON blocks';