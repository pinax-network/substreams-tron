INSERT INTO trc20_transfer_log_address_minutes
SELECT log_address, minute
FROM trc20_transfer;

INSERT INTO trc20_transfer_from_minutes
SELECT `from`, minute
FROM trc20_transfer;

INSERT INTO trc20_transfer_to_minutes
SELECT `to`, minute
FROM trc20_transfer;

INSERT INTO trc20_transfer_tx_hash_timestamps
SELECT tx_hash, timestamp
FROM trc20_transfer;

INSERT INTO trc20_transfer_block_hash_timestamps
SELECT block_hash, timestamp
FROM trc20_transfer;
