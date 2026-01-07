
docker compose -f deploy/docker-compose.yml down
docker compose -f deploy/docker-compose.yml up -d
docker exec -it deploy-nats-box-1 sh -c 'nats kv ls'
docker exec -it deploy-nats-box-1 sh -c 'nats server info'
# 列出所有连接到 NATS 服务器的客户端
docker exec -it deploy-nats-box-1 sh -c 'nats server report connections'
docker exec -it deploy-nats-box-1 sh -c 'nats server report accounts'

# 列出所有 JetStream 流
docker exec -it deploy-nats-box-1 sh -c 'nats stream ls -s nats://user:pass@nats-server:4222'
# 查看特定流的详细信息（Dynamo 使用的流通常以组件名称命名）
docker exec -it deploy-nats-box-1 sh -c 'nats stream info namespace-dynamo-component-backend-kv-events -s nats://user:pass@nats-server:4222'
# 列出所有 JetStream 消费者
docker exec -it deploy-nats-box-1 sh -c 'nats consumer ls namespace-dynamo-component-backend-kv-events -s nats://user:pass@nats-server:4222'

nats stream info namespace-dynamo-component-backend-kv-events -s nats://user:pass@nats-server:4222

#vllm ----> KvEventPublisher ----> nats  ---->   kv router
#vllm <---- KvEventPublisher <---- nats  <----   kv router

# 连接到本地 NATS 服务器并检查信息
docker exec -it deploy-nats-box-1 sh -c 'nats server info'

docker exec -it deploy-nats-box-1 sh -c 'curl -s http://nats-server:8222/'
docker exec -it deploy-nats-box-1 sh -c 'curl -s http://nats-server:8222/jsz'
docker exec -it deploy-nats-box-1 sh -c 'curl -s http://nats-server:8222/varz'
docker exec -it deploy-nats-box-1 sh -c 'curl -s http://nats-server:8222/subsz'

#
#use dynamo_runtime::transports::nats::Client;
#
##[tokio::main]
#async fn main() -> Result<(), Box<dyn std::error::Error>> {
#    // 创建 NATS 客户端
#    let client = Client::builder().connect().await?;
#
#    // 查看服务器信息
#    println!("NATS server: {}", client.addr());
#
#    // 列出所有 JetStream 流
#    println!("JetStream streams: {:?}", client.list_streams().await?);
#
#    // 查看特定流的信息
#    if let Ok(streams) = client.list_streams().await {
#        for stream in streams {
#            println!("Stream: {}", stream);
#
#            if let Ok(consumers) = client.list_consumers(&stream).await {
#                println!("Consumers: {:?}", consumers);
#            }
#
#            if let Ok(info) = client.stream_info(&stream).await {
#                println!("Stream info: {:?}", info);
#            }
#        }
#    }
#
#    Ok(())
#}


export current_tag=0.7.0
./container/build.sh --framework vllm --target local-dev --enable-kvbm --uid 1000
#docker build -f /root/dynamo/container/Dockerfile --target dev --platform linux/amd64 --build-arg DYNAMO_COMMIT_SHA=377e90d7619022927c63eaca68e3c225b5e3a34b --build-arg NIXL_REF=0.7.1 --build-arg BASE_IMAGE=nvcr.io/nvidia/cuda-dl-base --build-arg BASE_IMAGE_TAG=25.01-cuda12.8-devel-ubuntu24.04 --build-arg ENABLE_KVBM=true --build-arg NIXL_UCX_REF=v1.19.0 --tag dynamo-base:v0.7.0 /root/dynamo
#docker build -f /root/dynamo/container/Dockerfile.vllm --target dev --platform linux/amd64 --build-arg DYNAMO_COMMIT_SHA=377e90d7619022927c63eaca68e3c225b5e3a34b --build-arg NIXL_REF=0.7.1 --build-arg BASE_IMAGE=nvcr.io/nvidia/cuda-dl-base --build-arg BASE_IMAGE_TAG=25.01-cuda12.8-devel-ubuntu24.04 --build-arg ENABLE_KVBM=true --build-arg NIXL_UCX_REF=v1.19.0 --build-arg DYNAMO_BASE_IMAGE=dynamo-base:v0.7.0 --tag dynamo:v0.7.0-vllm --tag dynamo:latest-vllm /root/dynamo
#docker build --build-arg DEV_BASE=dynamo:v0.7.0-vllm --build-arg USER_UID=1000 --build-arg USER_GID=0 --build-arg ARCH=amd64 --file /root/dynamo/container/Dockerfile.local_dev --tag dynamo:v0.7.0-vllm-local-dev --tag dynamo:latest-vllm-local-dev /root/dynamo/container
docker save dynamo-base:v0.7.0 -o 79fb418a2a55.tar
ossutil cp 79fb418a2a55.tar oss://dynamo-images2/79fb418a2a55.tar
docker save dynamo:v0.7.0-vllm -o ddd0509543e3.tar
ossutil cp ddd0509543e3.tar oss://dynamo-images2/ddd0509543e3.tar






# dynamo: components/backends/vllm/src/dynamo/vllm/handlers.py: 184 行
# prefill worker 返回给 decode worker 的 KV transfer 参数，告诉 decode 去哪里拉取已经计算好的 prefill 阶段的 KV cache，以便继续生成 decode 阶段的 token
2025-09-07T07:05:29.071135Z DEBUG handlers.generate: kv transfer params: {'do_remote_prefill': True, 'do_remote_decode': False, 'remote_block_ids': [1, 2], 'remote_engine_id': '5f1cba5c-3231-4b30-9ea3-b393f5311e53', 'remote_host': '127.0.1.1', 'remote_port': 20420, 'tp_size': 1}

