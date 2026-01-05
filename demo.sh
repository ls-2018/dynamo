docker compose -f deploy/docker-compose.yml up -d

"--gpus=all",
"--network=host",
"--ipc=host",
"--cap-add=SYS_PTRACE",
"--shm-size=10G",
"--ulimit=memlock=-1",
"--ulimit=stack=67108864",
"--ulimit=nofile=65536:65536"

docker run --name dynamo -it --hostname dynamo -v /root/dynamo:/dynamo --workdir /dynamo -e HOME=/root -u root dynamo:latest-vllm-local-dev
