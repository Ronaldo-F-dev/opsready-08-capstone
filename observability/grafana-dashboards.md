# Synthèse — Dashboards Grafana

Résumé pour la soutenance. Détail complet : [`docs/prj7/grafana-dashboards.md`](https://github.com/Ronaldo-F-dev/devops-prj3/blob/main/docs/prj7/grafana-dashboards.md). JSON exportés : [`dashboards/`](https://github.com/Ronaldo-F-dev/devops-prj3/tree/main/dashboards) dans le dépôt applicatif.

## Deux dashboards

1. **Infrastructure Kubernetes** — CPU/RAM/disque des nodes, nombre de pods, état des nodes, usage par namespace et par workload
2. **Application KPS Tasks API** — pods blue/green, redémarrages, readiness, CPU/RAM, replicas disponibles par version

## Pourquoi deux dashboards ciblés plutôt qu'un import générique

Le chart `kube-prometheus-stack` fournit déjà une vingtaine de dashboards communautaires (Kubernetes, CoreDNS, etcd...) mais aucun spécifique à `kps-tasks-api`. Les deux dashboards créés répondent directement aux questions qu'un exploitant se pose sur cette application précise, plutôt que d'ajouter un dashboard générique de plus.

## État vérifié (Jour 1 du Projet 8)

Grafana accessible (`http://<IP-VPS>:30030`, HTTP 200), Prometheus reste la source de données par défaut. Preuve : [`evidence/grafana-dashboard.txt`](../evidence/grafana-dashboard.txt).
