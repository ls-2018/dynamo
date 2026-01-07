#!/usr/bin/env zsh
skopeo_copy gcr.io/kubebuilder/kube-rbac-proxy:v0.15.0 $(trans_image_name.py gcr.io/kubebuilder/kube-rbac-proxy:v0.15.0)
skopeo_copy gcr.io/kubebuilder/kube-rbac-proxy:v0.15.0-arm64 $(trans_image_name.py gcr.io/kubebuilder/kube-rbac-proxy:v0.15.0-arm64)
skopeo_copy nvcr.io/nvidia/ai-dynamo/kubernetes-operator:0.7.0 $(trans_image_name.py nvcr.io/nvidia/ai-dynamo/kubernetes-operator:0.7.0)
skopeo_copy docker.io/bitnamilegacy/etcd:3.5.18-debian-12-r5 $(trans_image_name.py docker.io/bitnamilegacy/etcd:3.5.18-debian-12-r5)
skopeo_copy docker.io/library/nats:2.10.21-alpine $(trans_image_name.py docker.io/library/nats:2.10.21-alpine)
skopeo_copy docker.io/natsio/nats-server-config-reloader:0.16.0 $(trans_image_name.py docker.io/natsio/nats-server-config-reloader:0.16.0)
skopeo_copy docker.io/natsio/nats-box:0.14.5 $(trans_image_name.py docker.io/natsio/nats-box:0.14.5)
skopeo_copy docker.io/bitnamisecure/git:latest $(trans_image_name.py docker.io/bitnamisecure/git:latest)
skopeo_copy docker.io/alpine/k8s:1.34.1 $(trans_image_name.py docker.io/alpine/k8s:1.34.1)



#同一节点内不同 GPU 之间使用张量并行（依赖NVLink 带来的低延迟），不同节点之间使用流水线并行或者专家并行
