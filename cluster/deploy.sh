#!/usr/bin/sh

read -p "Enter public IP (of any* instance): " PUBLIC_IP
read -p "Enter web port mapped by NodePort: " EXTERNAL_WEB_PORT
read -p "Enter server port mapped by NodePort: " EXTERNAL_SERVER_PORT

export API_SERVER=http://${PUBLIC_IP}:${EXTERNAL_SERVER_PORT}
export AUTH_SERVER=${API_SERVER}
export HOMEPAGE=http://${PUBLIC_IP}:${EXTERNAL_WEB_PORT}

export IMAGES_DIR=$(mktemp -d)
export PROXY_IMAGE="${PROXY_IMAGE}-cluster"
export SERVER_IMAGE="${SERVER_IMAGE}-cluster"
export WEB_IMAGE="${WEB_IMAGE}-cluster"

docker build \
    --tag "${PROXY_IMAGE}" \
    --build-arg SERVER_PORT="${SERVER_PORT}" \
    --build-arg WEB_PORT="${WEB_PORT}" \
    proxy/

echo "Archiving ${PROXY_IMAGE}"
docker save "${PROXY_IMAGE}" | gzip > ${IMAGES_DIR}/proxy.tar.gz

docker build \
    --tag "${SERVER_IMAGE}" \
    server/

echo "Archiving ${SERVER_IMAGE}"
docker save "${SERVER_IMAGE}" | gzip > ${IMAGES_DIR}/server.tar.gz

docker build \
    --tag "${WEB_IMAGE}" \
    --build-arg API_SERVER="${API_SERVER}" \
    --build-arg AUTH_SERVER="${AUTH_SERVER}" \
    --build-arg HOMEPAGE="${HOMEPAGE}" \
    web/

echo "Archiving ${WEB_IMAGE}"
docker save "${WEB_IMAGE}" | gzip > ${IMAGES_DIR}/web.tar.gz

read -p "Remember to add ${API_SERVER}/auth/spotify/callback to the list of Redirect URIs in the Spotify app!"

export RENDERED_K8S=$(mktemp -d)
python render.py k8s ${RENDERED_K8S}/

ansible-playbook \
    -i cluster/hosts.yml\
    cluster/deploy.yml

echo "The website is hosted at ${HOMEPAGE}"