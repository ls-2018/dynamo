docker compose -f deploy/docker-compose.yml down
docker compose -f deploy/docker-compose.yml up -d
docker exec -it deploy-nats-box-1 sh -c 'nats kv ls'
docker exec -it deploy-nats-box-1 sh -c 'nats server report connections'
docker exec -it deploy-nats-box-1 sh -c 'nats server report accounts'
docker exec -it deploy-nats-box-1 sh -c 'curl -s http://nats-server:8222/'
