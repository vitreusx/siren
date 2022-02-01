#!/usr/bin/sh

python k8s/resolver.py \
    -i k8s/proxy \
    -o resolved-k8s/proxy

ansible-playbook -i cluster/hosts.yml cluster/setup-proxy.yml