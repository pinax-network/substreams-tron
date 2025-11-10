INSERT INTO native_transfer_from_minutes
SELECT `from`, minute
FROM native_transfer;

INSERT INTO native_transfer_to_minutes
SELECT `to`, minute
FROM native_transfer;

INSERT INTO native_transfer_tx_hash_timestamps
SELECT tx_hash, timestamp
FROM native_transfer;

INSERT INTO native_transfer_block_hash_timestamps
SELECT block_hash, timestamp
FROM native_transfer;
