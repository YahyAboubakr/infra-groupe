# Rôle Ansible : `wazuh_agent` (SOC)

Installe, enrôle et démarre l'agent **Wazuh 4.x** sur vos machines Linux (**Debian / Ubuntu** et **RHEL / Rocky / AlmaLinux**).

## Prérequis réseau (OPNsense / pare-feu)
Depuis chaque machine cible vers le serveur Wazuh (`10.230.204.50`) :
* **`1515/tcp`** : enrôlement automatique
* **`1514/tcp`** : envoi des événements / alertes

## Variables disponibles (`defaults/main.yml`)

| Variable | Défaut | Description |
|---|---|---|
| `wazuh_manager_address` | `"10.230.204.50"` | IP ou FQDN du serveur Wazuh |
| `wazuh_agent_group` | `"default"` | Groupe d'agents (`default`, `k8s`, `iam`, `monitoring`...) — **doit exister sur le serveur Wazuh** |
| `wazuh_agent_name` | `""` | Nom personnalisé (par défaut : hostname) |
| `wazuh_extra_json_logs` | `[]` | Liste de fichiers JSON additionnels à surveiller (ex. `/var/log/kubernetes/audit.log`) |

## Utilisation

### Option 1 : Intégrer dans votre dépôt Ansible
Copiez `roles/wazuh_agent/` dans votre dossier `roles/` puis appelez le rôle :

```yaml
- name: Déploiement des agents Wazuh
  hosts: all
  become: true
  vars:
    wazuh_manager_address: "10.230.204.50"
    wazuh_agent_group: "default" # ou k8s / iam / monitoring
  roles:
    - wazuh_agent
```

### Option 2 : Exécution standalone (avec les fichiers fournis dans le zip)
```bash
# 1. Adaptez inventory.yml avec vos IPs et votre utilisateur SSH
# 2. Lancez le playbook :
ansible-playbook -i inventory.yml install_wazuh_agent.yml
```
