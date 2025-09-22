use substreams_tron_proto::{Block, TransactionCount};
use substreams_tron_common::{convert_block, create_sample_block};

/// Extract basic block information from Tron blocks
/// This is a demonstration handler that processes a sample block
#[substreams::handlers::map]
pub fn map_blocks() -> Result<Block, substreams::errors::Error> {
    // For demonstration purposes, we'll create a sample block
    // In a real implementation, this would receive the actual Tron block from the blockchain
    let sample_block = create_sample_block();
    let converted_block = convert_block(&sample_block);
    
    substreams::log::info!(
        "Processing Tron block #{} with {} transactions", 
        converted_block.header.as_ref().map(|h| h.number).unwrap_or(0),
        converted_block.transactions.len()
    );
    
    Ok(converted_block)
}

/// Extract transaction count from blocks  
#[substreams::handlers::map]
pub fn map_transaction_count() -> Result<TransactionCount, substreams::errors::Error> {
    // For demonstration purposes, we'll create a sample block
    let sample_block = create_sample_block();
    let tx_count = sample_block.transactions.len() as u64;
    
    substreams::log::info!(
        "Block #{} has {} transactions", 
        sample_block.header.number,
        tx_count
    );
    
    Ok(TransactionCount { count: tx_count })
}