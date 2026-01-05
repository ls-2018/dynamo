#!/usr/bin/env zsh

test -e ./yaml/grove.yaml || {
	helm template grove oci://ghcr.io/ai-dynamo/grove/grove-charts:v0.0.0-g0f07586 --namespace grove-system >./yaml/grove.yaml
}

trans_image_name.py ./yaml/grove.yaml

kubectl create ns grove-system
kubectl apply -f ./yaml/grove-crds --server-side
kubectl apply -f ./yaml/grove.yaml -n grove-system
