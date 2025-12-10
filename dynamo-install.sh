#!/usr/bin/env zsh
# 1. Set environment
set -x

export NAMESPACE=dynamo-system
export RELEASE_VERSION=0.7.0
# any version of Dynamo 0.3.2+ listed at https://github.com/ai-dynamo/dynamo/releases

# 2. Install CRDs (skip if on shared cluster where CRDs already exist)
helm fetch https://helm.ngc.nvidia.com/nvidia/ai-dynamo/charts/dynamo-crds-${RELEASE_VERSION}.tgz
helm install dynamo-crds dynamo-crds-${RELEASE_VERSION}.tgz --namespace default

# 3. Install Platform
helm fetch https://helm.ngc.nvidia.com/nvidia/ai-dynamo/charts/dynamo-platform-${RELEASE_VERSION}.tgz

helm template dynamo-platform dynamo-platform-${RELEASE_VERSION}.tgz --namespace ${NAMESPACE} --create-namespace \
	--set etcd.persistence.enabled=false \
	--set dynamo-operator.controllerManager.manager.image.pullPolicy=Always \
	--set nats.natsBox.enabled=true \
	--set nats.config.jetstream.fileStore.pvc.enabled=false --dry-run >./dynamo.yaml

kubectl create ns ${NAMESPACE}
#gsed -i 's@gcr.io/kubebuilder/kube-rbac-proxy:v0.15.0@gcr.io/kubebuilder/kube-rbac-proxy:v0.15.0-arm64@g' ./dynamo.yaml
gsed -i 's@natsio/nats-box:0.14.5@dockerproxy.zetyun.cn/docker.io/natsio/nats-box:0.14.5@g' ./dynamo.yaml
trans_image_name.py ./dynamo.yaml
kubectl -n dynamo-system apply -f ./dynamo.yaml

kubectl -n dynamo-system patch deployment dynamo-platform-dynamo-operator-controller-manager \
	--type='json' \
	-p='[
          {
              "op": "replace",
              "path": "/spec/template/spec/containers/0/imagePullPolicy",
              "value": "Always"
          },
          {
              "op": "replace",
              "path": "/spec/template/spec/containers/1/imagePullPolicy",
              "value": "Always"
          }
      ]'

k8s-empty-pod-by-filter.sh
#
## to pull model from HF
export HF_TOKEN=??
kubectl create secret generic hf-token-secret \
	--from-literal=HF_TOKEN="$HF_TOKEN" \
	-n ${NAMESPACE}

# Deploy any example (this uses vLLM with Qwen model using aggregated serving)
kubectl apply -f examples/backends/vllm/deploy/agg.yaml -n ${NAMESPACE}

## Check status
#kubectl get dynamoGraphDeployment -n ${NAMESPACE}
#.
## Test it
#kubectl port-forward svc/vllm-agg-frontend 8000:8000 -n ${NAMESPACE}
curl http://localhost:8000/v1/models


curl 127.0.0.1:8000/v1/chat/completions \
  -H "Content-Type: application/json" -v \
  -d '{
    "model": "/data/models--Qwen--Qwen3-0.6B/snapshots/c1899de289a04d12100db370d81485cdf75e47ca",
    "messages": [
    {
        "role": "user",
        "content": "In the heart of Eldoria, an ancient land of boundless magic and mysterious creatures, lies the long-forgotten city of Aeloria. Once a beacon of knowledge and power, Aeloria was buried beneath the shifting sands of time, lost to the world for centuries. You are an intrepid explorer, known for your unparalleled curiosity and courage, who has stumbled upon an ancient map hinting at ests that Aeloria holds a secret so profound that it has the potential to reshape the very fabric of reality. Your journey will take you through treacherous deserts, enchanted forests, and across perilous mountain ranges. Your Task: Character Background: Develop a detailed background for your character. Describe their motivations for seeking out Aeloria, their skills and weaknesses, and any personal connections to the ancient city or its legends. Are they driven by a quest for knowledge, a search for lost familt clue is hidden."
    }
    ],
    "stream": false,
    "max_tokens": 30
  }'