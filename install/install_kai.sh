#!/usr/bin/env zsh
#helm template kai-scheduler oci://ghcr.io/nvidia/kai-scheduler/kai-scheduler \
#  -n kai-scheduler \
#  --create-namespace \
#  --version v0.10.3 >./yaml/kai.yaml

trans_image_name.py ./yaml/kai.yaml

kubectl create ns kai-scheduler

kubectl -n kai-scheduler apply -f ./yaml/kai.yaml
# 使用yaml建的kai,如果这个job 这个job 没有立马清掉,operator 会启动失败, 该问题在 12.13之后的版本修复
# kubectl -n kai-scheduler delete job post-delete-cleanup --force
