#!/bin/bash
set -e

echo "🚀 Deploy Webserver"
ansible-playbook -i inventory/hosts.ini playbooks/webservers.yml

echo "🚀 Start Python-Webserver"
ansible-playbook -i inventory/hosts.ini playbooks/start_webservers.yml

echo "🚀 Deploy HAProxy Loadbalancer"
ansible-playbook -i inventory/hosts.ini playbooks/loadbalancer.yml

HAPROXY_CFG="{{ ansible_env.HOME }}/ansible-math-demo/etc/haproxy.cfg"
if [ -f "$HAPROXY_CFG" ]; then
    echo "🚀 Start HAProxy"
    sudo haproxy -f "$HAPROXY_CFG" &
else
    echo "⚠️ HAProxy config $HAPROXY_CFG nicht gefunden. HAProxy wird nicht gestartet."
fi

echo "🌐 Loadbalancer: http://localhost:8000"
echo "   Web1: http://localhost:8001"
echo "   Web2: http://localhost:8002"
echo "   Web3: http://localhost:8003"
