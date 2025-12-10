from huggingface_hub import snapshot_download

# 直接指定镜像地址下载
snapshot_download(
    repo_id="Qwen/Qwen3-0.6B",
    endpoint="https://hf-mirror.com",
    local_dir='./models'
)

#  huggingface-cli download Qwen/Qwen3-0.6B --local-dir /data/qwen3-0.6b --local-dir-use-symlinks False