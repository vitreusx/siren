#!/usr/bin/sh

read -p "Enter cluster IP: " CLUSTER_IP

export API_SERVER=http://${CLUSTER_IP}:${SERVER_PORT}
export AUTH_SERVER=${API_SERVER}
export HOMEPAGE=http://${CLUSTER_IP}:${WEB_PORT}

docker build \
    --tag "${SERVER_IMAGE}" \
    server/

echo "Loading ${SERVER_IMAGE} into minikube"
minikube image load "${SERVER_IMAGE}"

docker build \
    --tag "${WEB_IMAGE}" \
    --build-arg API_SERVER="${API_SERVER}" \
    --build-arg AUTH_SERVER="${AUTH_SERVER}" \
    --build-arg HOMEPAGE="${HOMEPAGE}" \
    web/

echo "Loading ${WEB_IMAGE} into minikube"
minikube image load "${WEB_IMAGE}"

read -p "Remember to add ${API_SERVER}/auth/spotify/callback to the list of Redirect URIs in the Spotify app!"

export RENDERED_K8S=$(mktemp -d)
python render.py k8s ${RENDERED_K8S}
kubectl apply --recursive -f ${RENDERED_K8S}/

echo "The website is hosted at ${HOMEPAGE}"