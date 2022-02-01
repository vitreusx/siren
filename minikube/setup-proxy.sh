#!/usr/bin/sh

docker build \
    --tag "${PROXY_IMAGE}" \
    --build-arg SERVER_PORT="${SERVER_PORT}" \
    --build-arg WEB_PORT="${WEB_PORT}" \
    proxy/

echo "Loading ${PROXY_IMAGE} into minikube"
minikube image load "${PROXY_IMAGE}"

python render.py minikube/proxy-service.yml.j2

echo "Deploying proxy service in order to determine cluster IP"
kubectl apply -f minikube/proxy-service.yml

echo "Reminder: running `minikube tunnel` may be required"