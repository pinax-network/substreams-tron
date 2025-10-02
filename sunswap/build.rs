use std::env;
use std::path::PathBuf;

fn main() {
    let out_dir = PathBuf::from(env::var("OUT_DIR").unwrap());

    prost_build::Config::new()
        .out_dir(&out_dir)
        .compile_protos(&["v1/sunswap.proto"], &["v1/"])
        .unwrap();

    // Tell Cargo to rerun this build script if the proto files change
    println!("cargo:rerun-if-changed=v1/sunswap.proto");
}
