#!/bin/bash
set +e # Continue on errors

COLOR_BLUE="\033[0;94m"
COLOR_GREEN="\033[0;92m"
COLOR_RESET="\033[0m"

# Print useful output for user
echo -e "${COLOR_BLUE}
     %########%      
     %###########%       ____                 _____                      
         %#########%    |  _ \   ___ __   __ / ___/  ____    ____   ____ ___ 
         %#########%    | | | | / _ \\\\\ \ / / \___ \ |  _ \  / _  | / __// _ \\
     %#############%    | |_| |(  __/ \ V /  ____) )| |_) )( (_| |( (__(  __/
     %#############%    |____/  \___|  \_/   \____/ |  __/  \__,_| \___\\\\\___|
 %###############%                                  |_|
 %###########%${COLOR_RESET}


Welcome to your development container!

This is how you can work with it:
- Files will be synchronized between your local machine and this container
- Some ports will be forwarded, so you can access this container via localhost
- Run \`${COLOR_GREEN}go run main.go${COLOR_RESET}\` to start the application
"

# Set terminal prompt
export PS1="\[${COLOR_BLUE}\]devspace\[${COLOR_RESET}\] ./\W \[${COLOR_BLUE}\]\\$\[${COLOR_RESET}\] "
if [ -z "$BASH" ]; then export PS1="$ "; fi

# Include project's bin/ folder in PATH
export PATH="./bin:$PATH"

source /etc/profile
set -x
rm /data/operator
cd deploy/cloud/operator/cmd/ && go build -o /data/operator . && cd -
dlv --listen=:2345 --headless=true --api-version=2 --accept-multiclient exec /data/operator -- &&
	--health-probe-bind-address=:8081 &&
	--metrics-bind-address=127.0.0.1:8080 &&
	--leader-elect &&
	--leader-election-id=dynamo.nvidia.com &&
	--leader-election-namespace=kube-system &&
	--natsAddr=nats://dynamo-platform-nats.dynamo-system.svc.cluster.local:4222 &&
	--etcdAddr=dynamo-platform-etcd.dynamo-system.svc.cluster.local:2379 &&
	--grove-termination-delay=4h &&
	--mpi-run-ssh-secret-name=mpi-run-ssh-secret &&
	--mpi-run-ssh-secret-namespace=dynamo-system &&
	--dgdr-profiling-cluster-role-name=dynamo-platform-dynamo-operator-dgdr-profiling &&
	--planner-cluster-role-name=dynamo-platform-dynamo-operator-planner &&
	--operator-version=0.7.0
