# Synthèse — Alertes Prometheus/Alertmanager

Résumé pour la soutenance. Détail complet : [`docs/prj7/alerting-rules.md`](https://github.com/Ronaldo-F-dev/devops-prj3/blob/main/docs/prj7/alerting-rules.md). Manifestes : [`monitoring/alerts/`](https://github.com/Ronaldo-F-dev/devops-prj3/tree/main/monitoring/alerts) dans le dépôt applicatif.

## 4 règles actives

| Alerte | Déclenchement | Sévérité |
|---|---|---|
| `KpsTaskApiPodNotReady` | Un pod applicatif n'est pas prêt depuis 2 min | warning |
| `KpsTaskApiPodRestarting` | Un pod a redémarré dans les 15 dernières minutes | warning |
| `KpsTaskApiUnavailable` | Aucun pod (blue ET green) n'est prêt depuis 1 min | critical |
| `KpsTaskApiHighCPU` | CPU d'un pod > 50 millicoeurs depuis 2 min | warning |

## Preuve déjà démontrée (Projet 7, Jour 4)

Une charge HTTP réelle générée sur le pod actif a fait passer son CPU de ~0,01 à ~1,86 cœur. `KpsTaskApiHighCPU` observée `firing` dans Prometheus puis `active` dans Alertmanager.

## Limite assumée

Aucune notification externe (Slack/email) configurée — optionnel pour ce parcours, la preuve dans Prometheus/Alertmanager/Grafana est jugée suffisante. À proposer comme amélioration en soutenance.

## État vérifié (Jour 1 du Projet 8)

4 `PrometheusRule` toujours chargées dans Prometheus (`/api/v1/rules`). Preuve : [`evidence/alert-triggered.txt`](../evidence/alert-triggered.txt) (Projet 7).
