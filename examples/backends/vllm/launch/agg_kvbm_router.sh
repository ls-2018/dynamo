#!/bin/bash
# SPDX-FileCopyrightText: Copyright (c) 2025 NVIDIA CORPORATION & AFFILIATES. All rights reserved.
# SPDX-License-Identifier: Apache-2.0
set -e
trap 'echo Cleaning up...; kill 0' EXIT

# Set deterministic hash for KV event IDs
export PYTHONHASHSEED=0

# Common configuration
MODEL="Qwen/Qwen3-0.6B"

# run frontend + KV router
python -m dynamo.frontend \
    --router-mode kv \
    --http-port 8000 \
    --router-reset-states &

# run workers with KVBM enabled
# --enforce-eager is added for quick deployment. for production use, need to remove this flag
# Each worker needs unique ZMQ ports to avoid KVBM coordination conflicts
DYN_KVBM_LEADER_ZMQ_PUB_PORT=56001 \
DYN_KVBM_LEADER_ZMQ_ACK_PORT=56002 \
CUDA_VISIBLE_DEVICES=0 DYN_KVBM_CPU_CACHE_GB=2 \
    python3 -m dynamo.vllm \
    --model $MODEL \
    --enforce-eager \
    --connector kvbm \
    --gpu-memory-utilization 0.4 \
    --kv-events-config '{"publisher":"zmq","topic":"kv-events","endpoint":"tcp://*:20080","enable_kv_cache_events":true}' &

DYN_KVBM_LEADER_ZMQ_PUB_PORT=56003 \
DYN_KVBM_LEADER_ZMQ_ACK_PORT=56004 \
VLLM_NIXL_SIDE_CHANNEL_PORT=20097 \
CUDA_VISIBLE_DEVICES=0 DYN_KVBM_CPU_CACHE_GB=2 \
    python3 -m dynamo.vllm \
    --model $MODEL \
    --enforce-eager \
    --connector kvbm \
    --gpu-memory-utilization 0.4 \
    --kv-events-config '{"publisher":"zmq","topic":"kv-events","endpoint":"tcp://*:20081","enable_kv_cache_events":true}'

#frontend
#pid 34803
#u_str ESTAB  0      0                                                                                       * 148273                         * 148272 users:(("python",pid=34803,fd=15))
#u_str ESTAB  0      0                                                                                       * 148269                         * 148270 users:(("python",pid=34803,fd=9))
#u_str ESTAB  0      0                                                                                       * 148270                         * 148269 users:(("python",pid=34803,fd=10))
#u_str ESTAB  0      0                                                                                       * 148272                         * 148273 users:(("python",pid=34803,fd=53))
#tcp   ESTAB  0      0                                                                                   [::1]:58816                      [::1]:4222   users:(("python",pid=34803,fd=26))
#tcp   ESTAB  0      0                                                                                   [::1]:51048                      [::1]:2379   users:(("python",pid=34803,fd=21))
#tcp   ESTAB  0      0                                                                                   [::1]:49316                      [::1]:4222   users:(("python",pid=34803,fd=45))
#tcp   ESTAB  0      0                                                                                   [::1]:49306                      [::1]:4222   users:(("python",pid=34803,fd=40))
#
#root@iZ6wecfcdkpkc6plwnf0thZ:~# netstat -ap|grep 34803
#tcp        0      0 0.0.0.0:8000            0.0.0.0:*               LISTEN      34803/python
#tcp        0      0 iZ6wecfcdkpkc6plw:33475 0.0.0.0:*               LISTEN      34803/python
#tcp6       0      0 localhost:58816         localhost:4222(nats)          ESTABLISHED 34803/python
#tcp6       0      0 localhost:51048         localhost:2379(etcd)          ESTABLISHED 34803/python
#tcp6       0      0 localhost:49316         localhost:4222(nats)          ESTABLISHED 34803/python
#tcp6       0      0 localhost:49306         localhost:4222(nats)          ESTABLISHED 34803/python

# worker 1
root@iZ6wecfcdkpkc6plwnf0thZ:~# ss -p |grep 34804
tcp   ESTAB  0      0                                                                               127.0.0.1:38606                  127.0.0.1:57001(56001)   users:(("python3",pid=34804,fd=74))
tcp   ESTAB  0      0                                                                                   [::1]:49300                      [::1]:4222           users:(("python3",pid=34804,fd=76))
tcp   ESTAB  0      0                                                                                   [::1]:44272                      [::1]:4222           users:(("python3",pid=34804,fd=39))
tcp   ESTAB  0      0                                                                                   [::1]:48854                      [::1]:2379           users:(("python3",pid=34804,fd=34))

root@iZ6wecfcdkpkc6plwnf0thZ:~# netstat -ap|grep 34804
tcp        0      0 localhost:38606         localhost:57001(56001)          ESTABLISHED 34804/python3
tcp6       0      0 localhost:49300         localhost:4222(nats)            ESTABLISHED 34804/python3
tcp6       0      0 localhost:44272         localhost:4222(nats)            ESTABLISHED 34804/python3
tcp6       0      0 localhost:48854         localhost:2379(etcd)            ESTABLISHED 34804/python3




# 20081   (56004  56003实际会加1000) 都是vllm 占用的
#root@iZ6wecfcdkpkc6plwnf0thZ:~# python3
#Python 3.10.12 (main, Aug 15 2025, 14:32:43) [GCC 11.4.0] on linux
#Type "help", "copyright", "credits" or "license" for more information.
#>>> import zmq
#>>> import json
#>>>
#>>> def subscribe_to_zmq(endpoint, topic):
#...     context = zmq.Context()
#...     socket = context.socket(zmq.SUB)
#...     socket.connect(endpoint)
#...     socket.setsockopt_string(zmq.SUBSCRIBE, topic)
#...     print(f"Subscribed to {endpoint} for topic '{topic}'")
#...
#...     while True:
#...         message = socket.recv()
#...         print(f"Received message: {message}")
#...
#>>> # 检查 vLLM 原始事件
#>>> subscribe_to_zmq("tcp://127.0.0.1:20080", "kv-events")
#Subscribed to tcp://127.0.0.1:20080 for topic 'kv-events'
#Received message: b'kv-events'
#Received message: b'\x00\x00\x00\x00\x00\x00\x00\x05'
#Received message: b'\x93\xcbA\xdaW\x1cfs\x8eQ\x91\x97\xabBlockStored\x91\xcf\xf3_\xe1{\r\x81\xa2L\xcf\xda2\x9f\xe1\xbf\x8a\xac\x01\xdc\x00\x10\xcd\x10y\xcd\x01;\xcd\x02\xa6\xcd\x03r\xce\x00\x02P]\xcc\xc6\xce\x00\x02P\\\xce\x00\x01-#\xcc\xc6\xce\x00\x02Ps\xcc\xc6\xcd~9\x0b\xcd\x03\x05\xcd\x01f\xcd\x04\xa0\x10\xc0\xa3GPU\x00'
#Received message: b'kv-events'


#v1/instances/dynamo/backend/clear_kv_blocks/694d9b90ff8deb4b
 #{"type":"Endpoint","component":"backend","endpoint":"clear_kv_blocks","namespace":"dynamo","instance_id":7587891994254240587,"transport":{"nats_tcp":"dynamo_backend.clear_kv_blocks-694d9b90ff8deb4b"}}
 #v1/instances/dynamo/backend/clear_kv_blocks/694d9b90ff8deb4c
 #{"type":"Endpoint","component":"backend","endpoint":"clear_kv_blocks","namespace":"dynamo","instance_id":7587891994254240588,"transport":{"nats_tcp":"dynamo_backend.clear_kv_blocks-694d9b90ff8deb4c"}}
 #v1/instances/dynamo/backend/generate/694d9b90ff8deb4b
 #{"type":"Endpoint","component":"backend","endpoint":"generate","namespace":"dynamo","instance_id":7587891994254240587,"transport":{"nats_tcp":"dynamo_backend.generate-694d9b90ff8deb4b"}}
 #v1/instances/dynamo/backend/generate/694d9b90ff8deb4c
 #{"type":"Endpoint","component":"backend","endpoint":"generate","namespace":"dynamo","instance_id":7587891994254240588,"transport":{"nats_tcp":"dynamo_backend.generate-694d9b90ff8deb4c"}}
 #v1/kv_routers/dynamo/backend/c08eb68a-2290-4eeb-a36f-0d9880539249
 #{
 #  "overlap_score_weight": 1.0,
 #  "router_temperature": 0.0,
 #  "use_kv_events": true,
 #  "router_replica_sync": false,
 #  "router_track_active_blocks": true,
 #  "router_snapshot_threshold": 1000000,
 #  "router_reset_states": true
 #}
 #v1/mdc/dynamo/backend/generate/694d9b90ff8deb4b
 #{"type":"Model","namespace":"dynamo","component":"backend","endpoint":"generate","instance_id":7587891994254240587,"card_json":{"display_name":"Qwen/Qwen3-0.6B","slug":"qwen_qwen3-0_6b","model_info":{"hf_config_json":{"path":"/home/dy
 #namo/.cache/huggingface/hub/models--Qwen--Qwen3-0.6B/snapshots/c1899de289a04d12100db370d81485cdf75e47ca/config.json","checksum":"blake3:d873e9bb2bd54ebf6c4a60732887a57c33881cca4b0d92ec5107e9cc4f023660"}},"tokenizer":{"hf_tokenizer_jso
 #n":{"path":"/home/dynamo/.cache/huggingface/hub/models--Qwen--Qwen3-0.6B/snapshots/c1899de289a04d12100db370d81485cdf75e47ca/tokenizer.json","checksum":"blake3:b0cb923fc505fdf0a53f0287654fa26577d3f333d4134350da0a97664b228739"}},"prompt
 #_formatter":{"hf_tokenizer_config_json":{"path":"/home/dynamo/.cache/huggingface/hub/models--Qwen--Qwen3-0.6B/snapshots/c1899de289a04d12100db370d81485cdf75e47ca/tokenizer_config.json","checksum":"blake3:4422061cdcb205f75bc448b09f4017f
 #8f2f92f172aeb2cf0248f4ce2f0f360e6"}},"gen_config":{"hf_generation_config_json":{"path":"/home/dynamo/.cache/huggingface/hub/models--Qwen--Qwen3-0.6B/snapshots/c1899de289a04d12100db370d81485cdf75e47ca/generation_config.json","checksum"
 #:"blake3:18b891ec9627c101a441aec842f39c05d9f13df63b4cfd4226594941d977a9a6"}},"context_length":40960,"kv_cache_block_size":16,"migration_limit":0,"model_type":"Chat | Completions","model_input":"Tokens","runtime_config":{"total_kv_bloc
 #ks":3483,"max_num_seqs":256,"max_num_batched_tokens":2048,"tool_call_parser":null,"reasoning_parser":null,"data_parallel_size":1},"media_decoder":null,"media_fetcher":null}}
 #v1/mdc/dynamo/backend/generate/694d9b90ff8deb4c
 #{"type":"Model","namespace":"dynamo","component":"backend","endpoint":"generate","instance_id":7587891994254240588,"card_json":{"display_name":"Qwen/Qwen3-0.6B","slug":"qwen_qwen3-0_6b","model_info":{"hf_config_json":{"path":"/home/dy
 #namo/.cache/huggingface/hub/models--Qwen--Qwen3-0.6B/snapshots/c1899de289a04d12100db370d81485cdf75e47ca/config.json","checksum":"blake3:d873e9bb2bd54ebf6c4a60732887a57c33881cca4b0d92ec5107e9cc4f023660"}},"tokenizer":{"hf_tokenizer_jso
 #n":{"path":"/home/dynamo/.cache/huggingface/hub/models--Qwen--Qwen3-0.6B/snapshots/c1899de289a04d12100db370d81485cdf75e47ca/tokenizer.json","checksum":"blake3:b0cb923fc505fdf0a53f0287654fa26577d3f333d4134350da0a97664b228739"}},"prompt
 #_formatter":{"hf_tokenizer_config_json":{"path":"/home/dynamo/.cache/huggingface/hub/models--Qwen--Qwen3-0.6B/snapshots/c1899de289a04d12100db370d81485cdf75e47ca/tokenizer_config.json","checksum":"blake3:4422061cdcb205f75bc448b09f4017f
 #8f2f92f172aeb2cf0248f4ce2f0f360e6"}},"gen_config":{"hf_generation_config_json":{"path":"/home/dynamo/.cache/huggingface/hub/models--Qwen--Qwen3-0.6B/snapshots/c1899de289a04d12100db370d81485cdf75e47ca/generation_config.json","checksum"
 #:"blake3:18b891ec9627c101a441aec842f39c05d9f13df63b4cfd4226594941d977a9a6"}},"context_length":40960,"kv_cache_block_size":16,"migration_limit":0,"model_type":"Chat | Completions","model_input":"Tokens","runtime_config":{"total_kv_bloc
 #ks":3114,"max_num_seqs":256,"max_num_batched_tokens":2048,"tool_call_parser":null,"reasoning_parser":null,"data_parallel_size":1},"media_decoder":null,"media_fetcher":null}}