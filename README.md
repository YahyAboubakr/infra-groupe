# Infra groupe : partie SOC

Ce dépôt couvre **ma part** de l'infra : détection et sécurité en production sur **XCP-ng / Xen Orchestra**.

| Moi (ce dépôt) | Mon binôme |
|---|---|
| Wazuh (SIEM/XDR) + agents sur toutes les VM | Samba AD (dc1, dc2) |
| Intégration syslog Suricata (IDS sur OPNsense) | Zabbix |
| Greenbone / OpenVAS (scan de vulnérabilités) | |

---

## VM déployées

| VM | Rôle | vCPU | RAM | Disque | IP (VLAN 30) |
|---|---|---|---|---|---|
| `wazuh1` | Wazuh all-in-one : indexer + manager + dashboard | 4 | 8 Gio | 50 Go | `192.168.30.20` |
| `gvm1` | Greenbone Community Containers (Docker) | 4 | 8 Gio | 60 Go | `192.168.30.30` |

**Suricata** tourne directement sur le pare-feu **OPNsense** déjà en place et envoie ses alertes en syslog (`514/udp`) à `wazuh1`.

---

## Arborescence

```text
.
├── README.md
├── terraform/
│   ├── main.tf                  # Provider Xen Orchestra + déploiement wazuh1 & gvm1
│   ├── variables.tf
│   ├── outputs.tf
│   ├── terraform.tfvars.example # À copier en terraform.tfvars
│   └── modules/vm/              # Module VM Debian 13 Cloud-Init sur XCP-ng
└── ansible/
    ├── ansible.cfg
    ├── inventory/
    │   ├── hosts.yml            # wazuh_server, greenbone, dc, zabbix, k8s_nodes
    │   └── group_vars/all/main.yml
    ├── playbooks/
    │   ├── site.yml             # Déploiement complet
    │   ├── wazuh.yml            # Serveur Wazuh (+ réception syslog OPNsense)
    │   ├── greenbone.yml        # Scanner Greenbone / OpenVAS
    │   └── agents.yml           # Agents Wazuh sur toutes les VM
    └── roles/
        ├── common/              # Base : paquets, NTP, DNS
        ├── wazuh_server/        # wazuh-install.sh -a, syslog OPNsense, LDAP dashboard
        ├── wazuh_agent/         # Dépôt APT + enrôlement automatique
        └── greenbone/           # Docker + compose officiel
```

---

## Déploiement

### 1. Provisionner les VM sur XCP-ng (Terraform)

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars   # Renseigner l'URL et les identifiants Xen Orchestra
terraform init
terraform apply
```

### 2. Configurer les services (Ansible)

```bash
cd ../ansible
ansible all -m ping
ansible-playbook playbooks/wazuh.yml
ansible-playbook playbooks/greenbone.yml
ansible-playbook playbooks/agents.yml
```

Accès :
- **Wazuh Dashboard :** `https://192.168.30.20`
- **Greenbone :** `http://192.168.30.30:9392`

---

## Flux réseau à ouvrir (OPNsense)

| Source | Destination | Ports | Usage |
|---|---|---|---|
| Toutes les VM et nœuds K8s | `wazuh1` | 1514/tcp, 1515/tcp | Agents, enrôlement |
| OPNsense | `wazuh1` | 514/udp | Syslog + alertes Suricata |
| Admins | `wazuh1` | 443/tcp | Dashboard |
| `gvm1` | Toutes zones | tous | Scans de vulnérabilités |
| Admins | `gvm1` | 9392/tcp | Interface web |
| `wazuh1`, `gvm1` | DC (IAM) | 53, 88, 389/636, 123/udp | DNS, Kerberos, LDAP(S), NTP |
