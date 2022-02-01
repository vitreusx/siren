#!/usr/bin/sh

test -n ${PUBLIC_IP}

export API_SERVER=http://${PUBLIC_IP}:${SERVER_PORT}
export AUTH_SERVER=${API_SERVER}
export HOMEPAGE=http://${PUBLIC_IP}:${WEB_PORT}

export IMAGES_DIR=$(mktemp -d) 

docker build \
    --tag "${PROXY_IMAGE}-cluster" \
    --build-arg SERVER_PORT="${SERVER_PORT}" \
    --build-arg WEB_PORT="${WEB_PORT}" \
    proxy/

docker save "${PROXY_IMAGE}-cluster" | gzip > ${IMAGES_DIR}/proxy.tar.gz

docker build \
    --tag "${SERVER_IMAGE}-cluster" \
    server/

docker save "${SERVER_IMAGE}-cluster" | gzip > ${IMAGES_DIR}/server.tar.gz

docker build \
    --tag "${WEB_IMAGE}-cluster" \
    --build-arg API_SERVER="${API_SERVER}" \
    --build-arg AUTH_SERVER="${AUTH_SERVER}" \
    --build-arg HOMEPAGE="${HOMEPAGE}" \
    web/

docker save "${WEB_IMAGE}-cluster" | gzip > ${IMAGES_DIR}/web.tar.gz

export K8S_DIR=$(mktemp -d)
python k8s/resolver.py -o ${K8S_DIR}

ansible-playbook -i cluster/hosts.yml cluster/deploy.yml