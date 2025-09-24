use sha2::{Digest, Sha256};
use substreams::hex;

pub type Address = Vec<u8>;
pub type Hash = Vec<u8>;
pub const NULL_ADDRESS: [u8; 20] = hex!("0000000000000000000000000000000000000000");
pub const NULL_HASH: [u8; 32] = hex!("0000000000000000000000000000000000000000000000000000000000000000");

const TRON_VERSION_BYTE: u8 = 0x41; // 'T' addresses on Tron

/// Compute the 4-byte checksum for Base58Check (double SHA-256, first 4 bytes).
fn checksum4(data: &[u8]) -> [u8; 4] {
    let h1 = Sha256::digest(data);
    let h2 = Sha256::digest(&h1);
    let mut out = [0u8; 4];
    out.copy_from_slice(&h2[..4]);
    out
}

/// Convert a 20-byte payload (typically address body) into a Tron Base58Check string.
/// This prepends the Tron version byte (0x41) and appends the checksum.
pub fn tron_base58_from_20(bytes20: &[u8]) -> Result<String, &'static str> {
    if bytes20.len() != 20 {
        return Err("expected exactly 20 bytes");
    }
    let mut data = Vec::with_capacity(21 + 4);
    data.push(TRON_VERSION_BYTE);
    data.extend_from_slice(bytes20);
    let chk = checksum4(&data);
    data.extend_from_slice(&chk);
    Ok(bs58::encode(data).into_string())
}

/// Same as above, but accepts either:
/// - 20 bytes (address body) -> will prepend 0x41
/// - 21 bytes (already includes a leading version byte)
pub fn tron_base58_from_bytes(bytes: &[u8]) -> Result<String, &'static str> {
    match bytes.len() {
        20 => tron_base58_from_20(bytes),
        21 => {
            if bytes[0] != TRON_VERSION_BYTE {
                return Err("unexpected version byte; expected 0x41");
            }
            let mut data = bytes.to_vec();
            let chk = checksum4(&data);
            data.extend_from_slice(&chk);
            Ok(bs58::encode(data).into_string())
        }
        _ => Err("expected 20 or 21 bytes"),
    }
}

/// Convenience: hex -> Tron Base58Check (accepts '41' + 20 bytes, or just 20 bytes).
pub fn tron_base58_from_hex(hexstr: &str) -> Result<String, String> {
    let raw = hex::decode(hexstr.trim_start_matches("0x")).map_err(|_| "invalid hex".to_string())?;
    tron_base58_from_bytes(&raw).map_err(|e| e.to_string())
}

/// Decode and validate a Tron Base58Check address string. Returns the 21-byte data:
/// [0x41, 20-byte-body]. Validates checksum and version.
pub fn tron_decode_verify(addr: &str) -> Result<[u8; 21], &'static str> {
    let decoded = bs58::decode(addr).into_vec().map_err(|_| "invalid base58")?;
    if decoded.len() != 25 {
        return Err("decoded length must be 25 bytes");
    }
    let (payload, chk_given) = decoded.split_at(21);
    let chk_calc = checksum4(payload);
    if chk_given != chk_calc {
        return Err("checksum mismatch");
    }
    if payload[0] != TRON_VERSION_BYTE {
        return Err("unexpected version byte; expected 0x41");
    }
    let mut out = [0u8; 21];
    out.copy_from_slice(payload);
    Ok(out)
}
