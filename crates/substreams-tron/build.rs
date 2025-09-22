use std::path::PathBuf;

fn main() {
    let proto_dir = PathBuf::from("../../proto");
    let protos = [proto_dir.join("sf/tron/type/v1/block.proto")];

    prost_build::Config::new()
        .bytes(&[".sf.tron.type.v1.Transaction.raw_data.data"])
        .compile_protos(&protos, &[proto_dir])
        .expect("compile proto");
}
