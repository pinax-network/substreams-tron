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

-- Hex-encoded ABI string -> UTF-8 text
CREATE OR REPLACE FUNCTION abi_hex_to_string AS (hex) ->
    if(
        hex IS NULL,
        NULL,
        replaceRegexpOne(                       -- rtrim trailing whitespace after decoding
            unhex(
                replaceRegexpOne(               -- drop trailing 00 padding bytes
                    substring(
                        replaceRegexpAll(
                            lower(if(startsWith(hex, '0x'), substring(hex, 3), hex)),
                            '\\s+', ''
                        ),
                        129                     -- skip 64+64 hex chars (offset + length)
                    ),
                    '(00)+$',
                    ''
                )
            ),
            '\\s+$', ''                         -- remove trailing space/tab/newline
        )
    );

-- Short hex (like 'FF' or '0x0A') -> UInt8
CREATE OR REPLACE FUNCTION abi_hex_to_uint8 AS (hex) ->
    if(
        hex IS NULL OR length(replaceRegexpAll(hex, '\\s+', '')) = 0,
        NULL,
        toUInt8(
            ascii(
                unhex(
                    right(
                        if(
                            length(replaceRegexpAll(lower(hex), '\\s+', '')) % 2 = 1,
                            concat('0', replaceRegexpAll(lower(hex), '\\s+', '')),
                            replaceRegexpAll(lower(hex), '\\s+', '')
                        ),
                        2  -- take last byte of 32-byte ABI word
                    )
                )
            )
        )
    );

-- Insert Native TRX
INSERT INTO metadata_rpc (
    contract,
    decimals_hex,
    name_hex,
    symbol_hex
)
VALUES
(
    'TXYZ1234567890ABCDEF1234567890ABCDEF',  -- contract
    '0x06',                                  -- decimals_hex (6 in hex)
    '0x54726f6e',                            -- name_hex ('Tron')
    '0x545258'                               -- symbol_hex ('TRX')
);

-- VIEW for easier querying
CREATE OR REPLACE VIEW metadata ON CLUSTER 'tokenapis-a' AS
SELECT
    contract,
    abi_hex_to_uint8(decimals_hex) AS decimals,
    abi_hex_to_string(name_hex) AS name,
    abi_hex_to_string(symbol_hex) AS symbol
FROM metadata_rpc
WHERE error = '';