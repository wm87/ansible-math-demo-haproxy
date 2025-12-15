#!/bin/bash
set -e

PROJECT="$HOME/ansible-math-demo"
echo "📂 Erstelle Projektstruktur in $PROJECT"
mkdir -p $PROJECT/{inventory,playbooks,roles/webserver/{tasks,templates,files},roles/loadbalancer/{tasks,templates},group_vars,www/web1,www/web2,www/web3,bin,etc}

# --------------------------
# 1. Inventory
# --------------------------
cat > $PROJECT/inventory/hosts.ini <<EOL
[webservers]
web1 ansible_connection=local web1_port=8001
web2 ansible_connection=local web2_port=8002
web3 ansible_connection=local web3_port=8003

[loadbalancer]
localhost ansible_connection=local lb_port=8000
EOL

# --------------------------
# 2. group_vars/all.yml
# --------------------------
cat > $PROJECT/group_vars/all.yml <<EOL
webservers:
  web1:
    port: 8001
  web2:
    port: 8002
  web3:
    port: 8003

lb_port: 8000
EOL

# --------------------------
# 3. roles/webserver/tasks/main.yml
# --------------------------
cat > $PROJECT/roles/webserver/tasks/main.yml <<'EOL'
---
- name: Ensure webserver directories exist
  file:
    path: "{{ item }}"
    state: directory
    mode: '0755'
  loop:
    - "{{ ansible_env.HOME }}/ansible-math-demo/www/web1"
    - "{{ ansible_env.HOME }}/ansible-math-demo/www/web2"
    - "{{ ansible_env.HOME }}/ansible-math-demo/www/web3"
    - "{{ ansible_env.HOME }}/ansible-math-demo/bin"

- name: Copy number generator script
  copy:
    src: generate_numbers.py
    dest: "{{ ansible_env.HOME }}/ansible-math-demo/bin/generate_numbers.py"
    mode: '0755'

- name: Generate dynamic numbers
  command: "{{ ansible_env.HOME }}/ansible-math-demo/bin/generate_numbers.py {{ inventory_hostname }}"
  register: numbers_output

- name: Deploy HTML page
  template:
    src: index.html.j2
    dest: "{{ ansible_env.HOME }}/ansible-math-demo/www/{{ inventory_hostname }}/index.html"
  vars:
    numbers: "{{ numbers_output.stdout }}"
EOL

# --------------------------
# 4. roles/webserver/templates/index.html.j2
# --------------------------
cat > $PROJECT/roles/webserver/templates/index.html.j2 <<'EOL'
<!DOCTYPE html>
<html lang="de">
<head>
<meta charset="UTF-8">
<title>Mathematik Demo - {{ inventory_hostname }}</title>
<style>
body {
    font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    margin: 0;
    padding: 0;
    background: linear-gradient(135deg,
                {% if inventory_hostname == 'web1' %}#d0f0c0, #a0e0a0
                {% elif inventory_hostname == 'web2' %}#c0d0f0, #80b0ff
                {% else %}#f0d0c0, #f08060{% endif %});
}
header {
    background: {% if inventory_hostname == 'web1' %}#4CAF50
                {% elif inventory_hostname == 'web2' %}#2196F3
                {% else %}#FF5722{% endif %};
    color: white;
    padding: 20px;
    text-align: center;
}
header h1 { margin: 0; font-size: 2em; }
header h2 { margin-top: 5px; font-size: 1.2em; }

main {
    display: flex;
    flex-wrap: wrap;
    justify-content: center;
    padding: 40px;
    gap: 15px;
}

.number-box {
    background: rgba(255,255,255,0.8);
    border-radius: 12px;
    padding: 20px;
    font-size: 1.5em;
    font-weight: bold;
    width: 80px;
    height: 80px;
    display: flex;
    justify-content: center;
    align-items: center;
    transition: transform 0.3s, background 0.3s;
    cursor: pointer;
    animation: popin 0.5s ease forwards;
}
.number-box:hover {
    transform: scale(1.3);
    background: rgba(255,255,255,1);
}
@keyframes popin {
    0% { transform: scale(0); opacity: 0; }
    100% { transform: scale(1); opacity: 1; }
}

footer {
    text-align: center;
    padding: 15px;
    background: rgba(0,0,0,0.2);
    font-size: 0.9em;
}

</style>
<script>
document.addEventListener('DOMContentLoaded', () => {
    const boxes = document.querySelectorAll('.number-box');
    boxes.forEach((box, index) => {
        box.style.animationDelay = (index * 0.1) + 's';
        box.addEventListener('click', () => {
            alert('Zahl: ' + box.innerText);
        });
    });
});
</script>
</head>
<body>
<header>
    <h1>
        Mathematik Demo - 
        {% if inventory_hostname == 'web1' %}
            Fibonacci-Zahlen
        {% elif inventory_hostname == 'web2' %}
            Primzahlen bis 100
        {% else %}
            Quadratzahlen
        {% endif %}
    </h1>
</header>
<main>
{% for n in numbers.split() %}
    <div class="number-box">{{ n }}</div>
{% endfor %}
</main>
<footer>
    &copy; TU Dresden - Mathematik Demo
</footer>
</body>
</html>
EOL

# --------------------------
# 5. roles/webserver/files/generate_numbers.py
# --------------------------
cat > $PROJECT/roles/webserver/files/generate_numbers.py <<'EOL'
#!/usr/bin/env python3
import sys

hostname = sys.argv[1]

def fibonacci(n):
    seq = [0, 1]
    for _ in range(2, n):
        seq.append(seq[-1] + seq[-2])
    return seq[:n]

def primes(n):
    if n < 2:
        return []
    result = [2]
    for num in range(3, n+1, 2):
        is_prime = True
        for i in range(3, int(num**0.5)+1, 2):
            if num % i == 0:
                is_prime = False
                break
        if is_prime:
            result.append(num)
    return result

def squares(n):
    return [i*i for i in range(1, n+1)]

if hostname == "web1":
    numbers = fibonacci(20)
elif hostname == "web2":
    numbers = primes(100)
else:  # web3
    numbers = squares(20)

print(" ".join(str(x) for x in numbers))
EOL

# --------------------------
# 6. roles/loadbalancer/tasks/main.yml
# --------------------------
cat > $PROJECT/roles/loadbalancer/tasks/main.yml <<'EOL'
---
- name: Deploy HAProxy config
  template:
    src: haproxy.cfg.j2
    dest: "{{ ansible_env.HOME }}/ansible-math-demo/etc/haproxy.cfg"
EOL

# --------------------------
# 7. roles/loadbalancer/templates/haproxy.cfg.j2
# --------------------------
cat > $PROJECT/roles/loadbalancer/templates/haproxy.cfg.j2 <<'EOL'
global
    maxconn 4096
    daemon

defaults
    mode http
    timeout connect 5000ms
    timeout client 50000ms
    timeout server 50000ms

frontend http_front
    bind *:{{ lb_port }}
    default_backend webservers

backend webservers
    balance roundrobin
    server web1 127.0.0.1:{{ hostvars['web1']['web1_port'] }} check
    server web2 127.0.0.1:{{ hostvars['web2']['web2_port'] }} check
    server web3 127.0.0.1:{{ hostvars['web3']['web3_port'] }} check
EOL

# --------------------------
# 8. playbooks/webservers.yml
# --------------------------
cat > $PROJECT/playbooks/webservers.yml <<'EOL'
---
- hosts: webservers
  vars_files:
    - ../group_vars/all.yml
  become: false
  roles:
    - webserver
EOL

# --------------------------
# 9. playbooks/start_webservers.yml
# --------------------------
cat > $PROJECT/playbooks/start_webservers.yml <<'EOL'
---
- hosts: webservers
  tasks:
    - name: Start Python HTTP Server in Hintergrund
      shell: >
        nohup python3 -m http.server {{ hostvars[inventory_hostname][inventory_hostname + '_port'] }}
        --directory {{ ansible_env.HOME }}/ansible-math-demo/www/{{ inventory_hostname }} > {{ ansible_env.HOME }}/ansible-math-demo/{{ inventory_hostname }}.log 2>&1 &
      args:
        executable: /bin/bash
      async: 0
      poll: 0
EOL

# --------------------------
# 10. playbooks/loadbalancer.yml
# --------------------------
cat > $PROJECT/playbooks/loadbalancer.yml <<'EOL'
---
- hosts: loadbalancer
  vars_files:
    - ../group_vars/all.yml
  become: false
  roles:
    - loadbalancer
EOL

# --------------------------
# 11. playbooks/cleanup.yml
# --------------------------
cat > $PROJECT/playbooks/cleanup.yml <<'EOL'
---
- hosts: webservers
  become: false
  tasks:
    - name: Remove generated HTML
      file:
        path: "{{ ansible_env.HOME }}/ansible-math-demo/www/{{ inventory_hostname }}/index.html"
        state: absent

    - name: Remove Python script
      file:
        path: {{ ansible_env.HOME }}/ansible-math-demo/bin/generate_numbers.py
        state: absent

- hosts: loadbalancer
  become: false
  tasks:
    - name: Remove HAProxy config
      file:
        path: {{ ansible_env.HOME }}/ansible-math-demo/etc/haproxy.cfg
        state: absent
EOL

# --------------------------
# 12. run.sh
# --------------------------
cat > $PROJECT/run.sh <<'EOL'
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
EOL
chmod +x $PROJECT/run.sh
