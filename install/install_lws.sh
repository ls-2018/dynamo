VERSION=v0.7.0

test -e ./yaml/lws.yaml || {
	wget -O yaml/lws.yaml https://github.com/kubernetes-sigs/lws/releases/download/$VERSION/manifests.yaml
}

trans_image_name.py ./yaml/lws.yaml

#kubectl delete -f ./yaml/lws.yaml -n lws-system
kubectl apply -f ./yaml/lws.yaml -n lws-system --server-side
