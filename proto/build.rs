fn main() {
    let mut config = prost_build::Config::new();
    config.protoc_arg("--experimental_allow_proto3_optional");

    config.compile_protos(&["v1/tron.proto"], &["v1/"]).unwrap();

    println!("cargo:rerun-if-changed=v1/");
}
