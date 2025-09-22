//! Tron Substreams protobuf bindings compiled from official definitions.

/// Generated protobuf modules.
pub mod pb {
    pub mod sf {
        pub mod tron {
            pub mod r#type {
                pub mod v1 {
                    include!(concat!(env!("OUT_DIR"), "/sf.tron.r#type.v1.rs"));
                }
            }
        }
    }

    pub mod protocol {
        include!(concat!(env!("OUT_DIR"), "/protocol.rs"));
    }
}
