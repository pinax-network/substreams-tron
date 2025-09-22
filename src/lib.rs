// Simple pass-through handler for raw bytes
#[substreams::handlers::map]
fn map_blocks(block: Vec<u8>) -> Result<Vec<u8>, substreams::errors::Error> {
    Ok(block)
}
