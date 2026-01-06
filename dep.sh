docker compose -f deploy/docker-compose.yml down
docker compose -f deploy/docker-compose.yml up -d
docker exec -it deploy-nats-box-1 sh -c 'nats kv ls'
docker exec -it deploy-nats-box-1 sh -c 'nats server info'
# 列出所有连接到 NATS 服务器的客户端
docker exec -it deploy-nats-box-1 sh -c 'nats server report connections'
docker exec -it deploy-nats-box-1 sh -c 'nats server report accounts'

# 列出所有 JetStream 流
docker exec -it deploy-nats-box-1 sh -c 'nats stream ls'

# 连接到本地 NATS 服务器并检查信息
docker exec -it deploy-nats-box-1 sh -c 'nats server info'

docker exec -it deploy-nats-box-1 sh -c 'curl -s http://nats-server:8222/'
docker exec -it deploy-nats-box-1 sh -c 'curl -s http://nats-server:8222/jsz'
docker exec -it deploy-nats-box-1 sh -c 'curl -s http://nats-server:8222/varz'
docker exec -it deploy-nats-box-1 sh -c 'curl -s http://nats-server:8222/subsz'



# 查看特定流的详细信息（Dynamo 使用的流通常以组件名称命名）
nats stream info <stream-name> -s nats://user:pass@nats-server:4222
# 列出所有 JetStream 消费者
nats consumer ls <stream-name> -s nats://user:pass@nats-server:4222









use dynamo_runtime::transports::nats::Client;

#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // 创建 NATS 客户端
    let client = Client::builder().connect().await?;

    // 查看服务器信息
    println!("NATS server: {}", client.addr());

    // 列出所有 JetStream 流
    println!("JetStream streams: {:?}", client.list_streams().await?);

    // 查看特定流的信息
    if let Ok(streams) = client.list_streams().await {
        for stream in streams {
            println!("Stream: {}", stream);

            if let Ok(consumers) = client.list_consumers(&stream).await {
                println!("Consumers: {:?}", consumers);
            }

            if let Ok(info) = client.stream_info(&stream).await {
                println!("Stream info: {:?}", info);
            }
        }
    }

    Ok(())
}