use substreams::Hex;

pub fn to_hex(bytes: &[u8]) -> String {
    if bytes.is_empty() {
        String::new()
    } else {
        format!("0x{}", Hex::encode(bytes))
    }
}

pub fn is_zero_amount(value: &str) -> bool {
    value.trim_start_matches('0').is_empty()
}
