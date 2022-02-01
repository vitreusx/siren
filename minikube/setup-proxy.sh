#!/usr/bin/sh

docker build \
    --tag "${PROXY_IMAGE}" \
    --build-arg SERVER_PORT="${SERVER_PORT}" \
    --build-arg WEB_PORT="${WEB_PORT}" \
    proxy/

echo "Loading ${PROXY_IMAGE} into minikube"
minikube image load "${PROXY_IMAGE}"

python k8s/resolver.py -i k8s/proxy -o resolved-k8s/proxy
kubectl apply -f resolved-k8s/proxy/service.yml

echo "Reminder: minikube tunnel may be required"