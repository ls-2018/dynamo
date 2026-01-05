#!/usr/bin/env bash
send wcni-kind /root/dynamo

ssh root@wcni-kind docker rm dynamo -f

ssh root@wcni-kind docker run \
	--name dynamo \
	-d \
	-p 2222:22 \
	--hostname dynamo \
	-v /root/dynamo:/dynamo \
	--workdir /dynamo \
	-e HOME=/root \
	-u root \
	dynamo:latest-vllm-local-dev \
	bash /dynamo/init-remote.sh

#docker run --name dynamo -it --hostname dynamo -v /root/dynamo:/dynamo --workdir /dynamo -e HOME=/root -u root dynamo:latest-vllm-local-dev

osascript <<'EOF'
tell application "iTerm"
  create window with default profile
  tell current session of current window
    write text "ssh wcni-kind 'docker logs -f dynamo'"
  end tell
end tell
EOF

until nc -z wcni-kind 2222; do
	sleep 1
done

echo "✅ wcni-kind:2222 is ready"

rm -rf ~/.ssh/known_hosts
sshpass -p 'f2uKSWNzV5RhTyxpe0o1' ssh-copy-id -o StrictHostKeyChecking=no -f -p 2222 root@wcni-kind

#ssh -p 2222 root@wcni-kind

#ARG IDE_CODE=RR
#ARG IDE_VERSION=2025.3.1
#
#mkdir -p ~/JetBrains \
#    && IDE_URL=$(curl -s "https://data.services.jetbrains.com/products/releases?code=${IDE_CODE}&majorVersion=${IDE_VERSION}&latest=true" | jq -r ".${IDE_CODE}[0].downloads.linux.link") \
#    && IDE_NAME=$(curl -s "https://data.services.jetbrains.com/products/releases?code=${IDE_CODE}&majorVersion=${IDE_VERSION}&latest=true" | jq -r ".${IDE_CODE}[0].name") \
#    && echo "Installing ${IDE_NAME}..." \
#    && wget -q ${IDE_URL} -P /tmp \
#    && tar -xzf /tmp/$(basename ${IDE_URL}) -C ~/JetBrains \
#    && rm -f /tmp/$(basename ${IDE_URL}) \
#    && echo "${IDE_NAME} installed successfully"
