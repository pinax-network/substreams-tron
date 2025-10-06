use proto::pb::tron::foundational_store::v1::Keys;

pub fn prefixed_key(prefix: Keys, key: Vec<u8>) -> Vec<u8> {
    let mut out = Vec::with_capacity(1 + key.len());
    out.push(prefix as i32 as u8); // safe since enum values are small ints
    out.extend_from_slice(&key);
    out
}
