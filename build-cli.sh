docker run \
  --rm \
  -it --gpus=all \
  --network=host \
  -e RUST_BACKTRACE=1 \
  --cap-add=SYS_PTRACE \
  -v /root/dynamo:/workspace \
  dynamo:latest-vllm-local-dev \
  bash


rustup target add x86_64-unknown-linux-gnu
#cargo build --release --features cuda -p dynamo-run --target x86_64-unknown-linux-gnu
cargo build --release -p dynamo-run --target x86_64-unknown-linux-gnu