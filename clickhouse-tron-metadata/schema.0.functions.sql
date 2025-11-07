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

CREATE OR REPLACE FUNCTION abi_hex_to_uint256 AS (hex) ->
    if(
        hex IS NULL OR length(replaceRegexpAll(hex, '\\s+', '')) = 0,
        NULL,
        toUInt256(
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

-- If empty string, return 0, if not parse as UInt256
CREATE OR REPLACE FUNCTION abi_hex_to_uint256_or_zero AS (hex) ->
    if(
        hex IS NULL OR length(replaceRegexpAll(hex, '\\s+', '')) = 0,
        toUInt256(0),
        abi_hex_to_uint256(hex)
    );
