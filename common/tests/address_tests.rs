use common::{tron_base58_from_20, tron_base58_from_bytes, tron_base58_from_hex, tron_decode_verify};

#[test]
fn test_encode_20_zeroes() {
    let body = [0u8; 20];
    let addr = tron_base58_from_20(&body).unwrap();
    assert_eq!(addr, "T9yD14Nj9j7xAB4dbGeiX9h8unkKHxuWwb");

    let decoded = tron_decode_verify(&addr).unwrap();
    assert_eq!(decoded[0], 0x41);
    assert_eq!(&decoded[1..], &body);
}

#[test]
fn test_encode_from_hex_with_41_prefix() {
    // well-known 41-prefixed hex
    let hex_str = "41d002c2f5b91353c1320e4d194d2d10e6b31dbe33";
    let addr = tron_base58_from_hex(hex_str).unwrap();
    assert_eq!(addr, "TUw4rqTx1tBvj5RosPfRW2dv38HoaC7yaR");

    let decoded = tron_decode_verify(&addr).unwrap();
    assert_eq!(decoded[0], 0x41);
    assert_eq!(hex::encode(&decoded[1..]), "d002c2f5b91353c1320e4d194d2d10e6b31dbe33");
}

#[test]
fn test_encode_from_21_bytes() {
    let bytes21 = hex::decode("41d002c2f5b91353c1320e4d194d2d10e6b31dbe33").unwrap();
    let addr = tron_base58_from_bytes(&bytes21).unwrap();
    assert_eq!(addr, "TUw4rqTx1tBvj5RosPfRW2dv38HoaC7yaR");
}

#[test]
fn test_invalid_length() {
    let bad = [0u8; 19]; // too short
    let err = tron_base58_from_bytes(&bad).unwrap_err();
    assert_eq!(err, "expected 20 or 21 bytes");
}

#[test]
fn test_invalid_checksum() {
    let body = [0u8; 20];
    let mut addr = tron_base58_from_20(&body).unwrap();
    // Corrupt last char
    addr.replace_range(addr.len() - 1.., "X");
    let err = tron_decode_verify(&addr).unwrap_err();
    assert_eq!(err, "checksum mismatch");
}

#[test]
fn test_invalid_version_byte() {
    // Construct 21 bytes starting with wrong version (0x01)
    let mut data = vec![0x01];
    data.extend_from_slice(&[0u8; 20]);
    let err = tron_base58_from_bytes(&data).unwrap_err();
    assert_eq!(err, "unexpected version byte; expected 0x41");
}

#[test]
fn test_encode_from_hex_solscan() {
    assert_eq!(
        tron_base58_from_hex("5e5602e054d1da6a43c83d9f8774daf15d79d210").unwrap(),
        "TJa1ZFq2UzaXZqfw7F7hjfRmiQxWWBkCzS"
    );
    assert_eq!(
        tron_base58_from_hex("72c28b75b5e60469ac187174a296683680ae8a58").unwrap(),
        "TLS168n4rPdVbZQDoDCjj57axRZTyZ9vJh"
    );
}
