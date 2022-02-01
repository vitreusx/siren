#!/usr/bin/sh

python render.py cluster/proxy-service.yml.j2

ansible-playbook \
    -i cluster/hosts.yml \
    cluster/setup-proxy.yml