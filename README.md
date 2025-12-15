[![Ansible](https://img.shields.io/badge/Ansible-2.9+-blue)](https://www.ansible.com/)
[![HAProxy](https://img.shields.io/badge/HAProxy-latest-blue?logo=haproxy)](http://www.haproxy.org/)
[![Python](https://img.shields.io/badge/Python-3.x-yellow)](https://www.python.org/)
[![HTML5](https://img.shields.io/badge/HTML5-E34F26?logo=html5&logoColor=white)](https://developer.mozilla.org/en-US/docs/Web/HTML)
[![JavaScript](https://img.shields.io/badge/JavaScript-ES6-F7DF1E?logo=javascript&logoColor=black)](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
[![CSS3](https://img.shields.io/badge/CSS3-1572B6?logo=css3&logoColor=white)](https://developer.mozilla.org/en-US/docs/Web/CSS)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)

# Mathe-Demo Deployment mit Ansible & HAProxy


## 🚀 Projektübersicht

Dieses Projekt demonstriert ein **vollständig automatisiertes Deployment** eines dynamischen Webserver-Clusters mit mathematischen Visualisierungen, orchestriert über **Ansible** und loadbalanced über **HAProxy**.

Die Demo zeigt praxisnah folgende Fähigkeiten:

* Automatisierung von Server-Deployments mit Ansible-Rollen
* Dynamische Generierung von mathematischen Inhalten (Fibonacci, Primzahlen, Quadratzahlen) via Python
* Multi-Webserver-Setup mit Load Balancing über HAProxy
* Responsives, modernes Frontend mit Animationen und interaktiven Zahlenelementen
* Sauberes Projekt- und Rollen-Layout für skalierbare Infrastruktur

---

## 🖥️ Architektur

```
          ┌─────────────┐
          │ Loadbalancer│
          │  HAProxy    │
          └──────┬──────┘
                 │
      ┌──────────┼─────────────────┐
      │          │                 │
┌─────▼──────┐┌──▼─────────┐┌──────▼────────┐
│ Web1       ││ Web2       ││ Web3          │
│ Fibonacci  ││ Primzahlen ││ Quadratzahlen │
└────────────┘└────────────┘└───────────────┘
```

* **Web1:** Fibonacci-Zahlen (Port 8001)
* **Web2:** Primzahlen bis 100 (Port 8002)
* **Web3:** Quadratzahlen (Port 8003)
* **Loadbalancer:** HAProxy (Port 8000, Round-Robin)

---

## ⚙️ Features

### Automatisierung

* Einrichtung von Webservern und Verzeichnissen automatisch via Ansible
* Deployment von dynamischen HTML-Seiten
* HAProxy Konfiguration & Deployment über Ansible-Templates

### Dynamische Inhalte

* Python-Skript generiert Zahlen für jeden Server
* HTML-Seiten visualisieren die Zahlen in interaktiven Boxen mit Animationen
* Click-to-Alert Funktion für jede Zahl

### Skalierbarkeit

* Einfaches Hinzufügen neuer Webserver durch Anpassen von Inventory und group_vars
* Load Balancer verteilt Anfragen automatisch auf alle Webserver

### Modernes Frontend

* CSS-Animationen für Pop-in Effekte
* Farblich differenzierte Hintergrundverläufe pro Webserver
* Responsive Layout für Desktop und Tablet

---

## 🛠️ Installation & Nutzung

1. **Projekt erstellen:**

```bash
bash install.sh
```

2. **Webserver und Loadbalancer starten:**

```bash
bash run.sh
```

3. **Webseiten erreichen:**

* HAProxy Loadbalancer: [http://localhost:8000](http://localhost:8000)
* Web1: [http://localhost:8001](http://localhost:8001)
* Web2: [http://localhost:8002](http://localhost:8002)
* Web3: [http://localhost:8003](http://localhost:8003)

4. **Cleanup:**

```bash
ansible-playbook -i inventory/hosts.ini playbooks/cleanup.yml
```

---

## 🔧 Anforderungen

* Linux
* Python 3.x
* Ansible 2.9+
* HAProxy (für Load Balancer)

---

## 📂 Projektstruktur

```
ansible-math-demo/
├── inventory/
├── playbooks/
├── roles/
│   ├── webserver/
│   │   ├── tasks/
│   │   ├── templates/
│   │   └── files/
│   └── loadbalancer/
│       ├── tasks/
│       └── templates/
├── group_vars/
├── www/
│   ├── web1/
│   ├── web2/
│   └── web3/
├── bin/
├── etc/
├── run.sh
└── README.md
```

---

## 📝 Lizenz

MIT License
