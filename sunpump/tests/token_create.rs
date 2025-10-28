#[cfg(test)]
mod tests {
    use substreams::hex;
    use substreams::scalar::BigInt;
    use substreams_abis::tvm::sunpump::v1::launchpad::events::TokenCreateV2;
    use substreams_ethereum::pb::eth::v2::Log;
    use substreams_ethereum::Event;

    #[test]
    fn test_sunpump_token_create() {
        // log: trx = bccd5365674cd7b193adbbb37b247bd84d41ae5c73be98ac3fc4150c2a1369fb
        // log: log.address = TEPcBKJB7N6rF9xKQKPVeSrscsRTfsVFVi
        // log: log.topics[0] = 16624d4e070855bf4f06e05f0fc8f60958fbb7fc14336e1d4f94df210e2d585a
        // log: log.data =
        // 000000000000000000000000afa761010e3d6180661ff902a70a265733d3b1f600000000000000000000000092ad9f5f8d9750e0
        // 3b310bbc2712121d8785c5360000000000000000000000000000000000000000000000000000000000000064000000000000000000000000000
        // 000000000000000000000000000000098968000000000000000000000000000000000000000000000000000000000000000c000000000000000
        // 0000000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000095
        // 4726f6e5f42756c6c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
        // 00000000000442554c4c00000000000000000000000000000000000000000000000000000000

        let log = Log {
            topics: vec![
                hex!("16624d4e070855bf4f06e05f0fc8f60958fbb7fc14336e1d4f94df210e2d585a").to_vec(), // topic0 (event signature)
            ],
            data: hex!(
                "000000000000000000000000afa761010e3d6180661ff902a70a265733d3b1f600000000000000000000000092ad9f5f8d9750e03b310bbc2712121d8785c5360000000000000000000000000000000000000000000000000000000000000064000000000000000000000000000000000000000000000000000000000098968000000000000000000000000000000000000000000000000000000000000000c00000000000000000000000000000000000000000000000000000000000000100000000000000000000000000000000000000000000000000000000000000000954726f6e5f42756c6c0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000442554c4c00000000000000000000000000000000000000000000000000000000"
            )
            .to_vec(),
            address: vec![],
            block_index: 0,
            index: 0,
            ordinal: 0,
        };

        match TokenCreateV2::match_and_decode(&log) {
            Some(event) => {
                assert_eq!(
                    event.token_address,
                    hex!("afa761010e3d6180661ff902a70a265733d3b1f6"),
                    "Token address should match"
                );
                assert_eq!(event.token_index, BigInt::from(100), "Token index should be 100");
                assert_eq!(event.creator, hex!("92ad9f5f8d9750e03b310bbc2712121d8785c536"), "Creator address should match");
                assert_eq!(event.initial_supply, BigInt::from(10_000_000), "Initial supply should be 10,000,000");
                assert_eq!(event.name, "Tron_Bull", "Name should match");
                assert_eq!(event.symbol, "BULL", "Symbol should match");
            }
            None => {
                panic!("Error decoding TokenCreate event");
            }
        }
    }
}
