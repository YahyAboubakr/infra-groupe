# Exécuté par gvm-script dans le conteneur gvm-tools.
# gvm-script fournit deux variables : `gmp` (connexion à gvmd) et `args`.
# Lit /automation/targets.json (généré par Ansible) et crée ce qui manque.
# Sortie : lignes "CHANGED ..." (Ansible s'en sert pour changed_when), "WARN ...".
# Code retour 2 = feeds pas encore prêtes (Ansible réessaie).
import json
import sys

from gvm.errors import GvmError

CONFIG_FILE = "/automation/targets.json"
SCANNER_NAME = "OpenVAS Default"
ALL = "rows=-1"  # filtre GMP : pas de pagination


def find_by_name(elements, name):
    for el in elements:
        if el.findtext("name") == name:
            return el
    return None


def require_id(elements, name, kind):
    el = find_by_name(elements, name)
    if el is None:
        print(f"ERREUR {kind} '{name}' introuvable (feeds pas encore synchronisées ?)")
        sys.exit(2)
    return el.get("id")


def ensure_target(gmp, existing_targets, port_lists, t):
    name = t["name"]
    hosts = sorted(set(t["hosts"]))
    target = find_by_name(existing_targets, name)

    if target is None:
        resp = gmp.create_target(
            name=name,
            hosts=hosts,
            exclude_hosts=t.get("exclude") or None,
            port_list_id=require_id(port_lists, t.get("port_list", "All IANA assigned TCP"), "liste de ports"),
            comment="Géré par Ansible",
        )
        print(f"CHANGED cible {name} créée : {', '.join(hosts)}")
        return resp.get("id")

    target_id = target.get("id")
    current = sorted(h.strip() for h in (target.findtext("hosts") or "").split(",") if h.strip())
    if current != hosts:
        try:
            gmp.modify_target(target_id, hosts=hosts)
            print(f"CHANGED cible {name} : {current} -> {hosts}")
        except GvmError as e:
            # gvmd refuse de modifier les hôtes d'une cible déjà utilisée par une tâche
            print(f"WARN cible {name} non modifiable ({e}) : supprime la tâche et la cible dans l'interface puis relance")
    return target_id


def ensure_task(gmp, existing_tasks, configs, scanner_id, target_id, t, start):
    task_name = f"Scan-{t['name']}"
    task = find_by_name(existing_tasks, task_name)

    if task is None:
        resp = gmp.create_task(
            name=task_name,
            config_id=require_id(configs, t.get("scan_config", "Full and fast"), "config de scan"),
            target_id=target_id,
            scanner_id=scanner_id,
            comment="Géré par Ansible",
        )
        task_id, status = resp.get("id"), "New"
        print(f"CHANGED tâche {task_name} créée")
    else:
        task_id, status = task.get("id"), task.findtext("status")

    if start and status not in ("Requested", "Queued", "Running"):
        gmp.start_task(task_id)
        print(f"CHANGED tâche {task_name} lancée")


def main(gmp, args):
    with open(CONFIG_FILE, encoding="utf-8") as f:
        conf = json.load(f)

    existing_targets = gmp.get_targets(filter_string=ALL).xpath("target")
    existing_tasks = gmp.get_tasks(filter_string=ALL).xpath("task")
    configs = gmp.get_scan_configs(filter_string=ALL).xpath("config")
    port_lists = gmp.get_port_lists(filter_string=ALL).xpath("port_list")
    scanners = gmp.get_scanners(filter_string=ALL).xpath("scanner")
    scanner_id = require_id(scanners, SCANNER_NAME, "scanner")

    for t in conf["targets"]:
        target_id = ensure_target(gmp, existing_targets, port_lists, t)
        ensure_task(gmp, existing_tasks, configs, scanner_id, target_id, t, conf.get("start_scans", False))


if __name__ == "__gmp__":
    main(gmp, args)