#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
set -e
trap 'echo Cleaning up...; kill 0' EXIT

# run ingress
python -m dynamo.frontend --http-port=8000 &

# run worker
# --enforce-eager is added for quick deployment. for production use, need to remove this flag
DYN_SYSTEM_PORT=8081 \
    python -m dynamo.vllm --model Qwen/Qwen3-0.6B --enforce-eager --connector none


#v1/instances/dynamo/backend/clear_kv_blocks/694d9b90ff8dea03
#{"type":"Endpoint","component":"backend","endpoint":"clear_kv_blocks","namespace":"dynamo","instance_id":7587891994254240259,"transport":{"nats_tcp":"dynamo_backend.clear_kv_blocks-694d9b90ff8dea03"}}

#v1/instances/dynamo/backend/generate/694d9b90ff8dea03
#{"type":"Endpoint","component":"backend","endpoint":"generate","namespace":"dynamo","instance_id":7587891994254240259,"transport":{"nats_tcp":"dynamo_backend.generate-694d9b90ff8dea03"}}

#v1/mdc/dynamo/backend/generate/694d9b90ff8dea03
#{"type":"Model","namespace":"dynamo","component":"backend","endpoint":"generate","instance_id":7587891994254240259,"card_json":{"display_name":"Qwen/Qwen3-0.6B","slug":"qwen_qwen3-0
#_6b","model_info":{"hf_config_json":{"path":"/home/dynamo/.cache/huggingface/hub/models--Qwen--Qwen3-0.6B/snapshots/c1899de289a04d12100db370d81485cdf75e47ca/config.json","checksum":
#"blake3:d873e9bb2bd54ebf6c4a60732887a57c33881cca4b0d92ec5107e9cc4f023660"}},"tokenizer":{"hf_tokenizer_json":{"path":"/home/dynamo/.cache/huggingface/hub/models--Qwen--Qwen3-0.6B/sn
#apshots/c1899de289a04d12100db370d81485cdf75e47ca/tokenizer.json","checksum":"blake3:b0cb923fc505fdf0a53f0287654fa26577d3f333d4134350da0a97664b228739"}},"prompt_formatter":{"hf_token
#izer_config_json":{"path":"/home/dynamo/.cache/huggingface/hub/models--Qwen--Qwen3-0.6B/snapshots/c1899de289a04d12100db370d81485cdf75e47ca/tokenizer_config.json","checksum":"blake3:
#4422061cdcb205f75bc448b09f4017f8f2f92f172aeb2cf0248f4ce2f0f360e6"}},"gen_config":{"hf_generation_config_json":{"path":"/home/dynamo/.cache/huggingface/hub/models--Qwen--Qwen3-0.6B/s
#napshots/c1899de289a04d12100db370d81485cdf75e47ca/generation_config.json","checksum":"blake3:18b891ec9627c101a441aec842f39c05d9f13df63b4cfd4226594941d977a9a6"}},"context_length":409
#60,"kv_cache_block_size":16,"migration_limit":0,"model_type":"Chat | Completions","model_input":"Tokens","runtime_config":{"total_kv_blocks":10641,"max_num_seqs":256,"max_num_batche
#d_tokens":2048,"tool_call_parser":null,"reasoning_parser":null,"data_parallel_size":1},"media_decoder":null,"media_fetcher":null}}