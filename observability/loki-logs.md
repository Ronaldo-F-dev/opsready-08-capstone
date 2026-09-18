# Synthèse — Logs Loki/Promtail

Résumé pour la soutenance. Détail complet : [`docs/prj7/loki-promtail-logs.md`](https://github.com/Ronaldo-F-dev/devops-prj3/blob/main/docs/prj7/loki-promtail-logs.md).

## Chaîne de collecte

`Application (stdout/stderr) → Promtail (DaemonSet, un pod par nœud) → Loki (stockage, filesystem local) → Grafana (consultation)`

## Requêtes utiles (LogQL)

| Besoin | Requête |
|---|---|
| Logs d'un namespace | `{namespace="kps-tasks"}` |
| Logs d'une application (toutes versions) | `{app="kps-tasks-api"}` |
| Logs contenant une erreur | `{namespace="kps-tasks"} \|= "ERROR"` (ou tout autre motif, ex. `"404"`) |

## Preuve déjà démontrée (Projet 7, Jour 3)

Une vraie erreur applicative déclenchée (`GET /tasks/999999` → 404) puis retrouvée dans Loki en quelques secondes avec `{namespace="kps-tasks"} \|= "404"`.

## État vérifié (Jour 1 du Projet 8)

`loki-0` et `loki-promtail-*` toujours `Running`. Preuve : [`evidence/loki-logs.txt`](../evidence/loki-logs.txt).
