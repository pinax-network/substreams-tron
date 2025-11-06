CREATE TABLE IF NOT EXISTS metadata_rpc (
    contract                 String,
    decimals_hex             String,
    name_hex                 String,
    symbol_hex               String,
    last_update              DateTime('UTC') DEFAULT now(),
    error                    String DEFAULT ''
)
ENGINE = ReplacingMergeTree
ORDER BY ( contract );

-- Insert Native TRX
INSERT INTO metadata_rpc (
    contract,
    decimals_hex,
    name_hex,
    symbol_hex
)
-- 6/Tron/TRX
VALUES (
    'T0000000000000000000000000000000000000001',
    '0x0000000000000000000000000000000000000000000000000000000000000006',
    '0x0000000000000000000000000000000000000000000000000000000000000020000000000000000000000000000000000000000000000000000000000000000454726f6e00000000000000000000000000000000000000000000000000000000',
    '0x000000000000000000000000000000000000000000000000000000000000002000000000000000000000000000000000000000000000000000000000000000035452580000000000000000000000000000000000000000000000000000000000',
);

-- VIEW for easier querying
CREATE OR REPLACE VIEW metadata AS
SELECT
    contract,
    abi_hex_to_uint8(decimals_hex) AS decimals,
    abi_hex_to_string(name_hex) AS name,
    abi_hex_to_string(symbol_hex) AS symbol
FROM metadata_rpc
WHERE error = '';