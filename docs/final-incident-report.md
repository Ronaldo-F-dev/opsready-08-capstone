# Rapport d'incident final — Projet 8, Jour 3

## Date et heure

- **Déclenchement** : 2026-09-21, ~06:25 UTC
- **Symptôme apparu** : ~06:26 UTC (pod `green` `Running` mais `0/1 Ready`)
- **Alerte `firing`** : ~06:28 UTC (2 minutes après le début de la condition, seuil `for: 2m` de la règle)
- **Résolution** : ~06:32 UTC
- **Durée totale de l'incident** : ~7 minutes

## Contexte

Ce scénario a été choisi parmi la liste du brief (« readinessProbe cassée »), volontairement différent de l'incident du Projet 7 (tag d'image invalide) pour couvrir un mode de panne distinct : un pod qui démarre, tourne, ne plante jamais, mais n'est **jamais prêt** à recevoir du trafic.

## Incident observé

Le chemin HTTP configuré sur la `readinessProbe` du déploiement `kps-tasks-api-green` a été modifié par erreur de `/health` vers `/healthz` (chemin inexistant) dans le dépôt GitOps. ArgoCD a synchronisé ce changement, provoquant le remplacement du pod `green` sain par un nouveau pod dont la probe de disponibilité échoue systématiquement.

## Impact

**Aucun impact utilisateur.** Le Service `kps-tasks-api` route le trafic exclusivement vers `version=blue` (non concernée par ce changement) — vérifié tout au long de l'incident (`curl http://<IP-VPS>:30080/health` → `200` sans interruption). L'impact réel est resté confiné à la version standby `green`, qui serait devenue inutilisable pour une future bascule blue/green ou un rollback si l'incident n'avait pas été corrigé — exactement le type de panne « silencieuse » qu'une supervision continue permet d'attraper avant qu'elle ne devienne critique.

## Symptôme

```
kubectl get pods -n kps-tasks
kps-tasks-api-green-786d9cc77b-8zt7b   0/1   Running   0   27s
```

Signature distincte d'un crash : `RESTARTS` reste à `0`. Le conteneur tourne, seule sa probe de disponibilité échoue.

## Détection et outils utilisés (dans l'ordre suivi)

1. **Dashboard application (Grafana/Prometheus)** — `kube_pod_status_ready{condition="false"}` = `1` pour le nouveau pod : premier signal visuel, sans avoir encore besoin d'un accès `kubectl`.
2. **Alertmanager / règles Prometheus** — `KpsTaskApiPodNotReady` passée `pending` puis `firing` (délai de 2 minutes, conforme au `for:` de la règle) : confirme que la détection automatique fonctionne, pas seulement un dashboard consulté par hasard.
3. **Logs Loki** — élément décisif du diagnostic : logs répétés toutes les ~10 secondes montrant `GET /healthz -> 404`, alternant avec `GET / -> 200` (la `livenessProbe`, elle, réussit). Cette seule observation isole déjà le problème : l'application répond normalement, seul un chemin précis échoue.
4. **ArgoCD** — `kps-tasks-api-dev` → `Synced` (donc le manifeste erroné vient bien de Git, pas d'une modification manuelle du cluster) / `Progressing` (bloqué, car le nouveau pod n'atteint jamais `Ready`).
5. **`kubectl describe pod`** — confirmation explicite dans les événements : `Warning Unhealthy ... Readiness probe failed: HTTP probe failed with statuscode: 404` (répété 8 fois en 65 secondes).
6. **`kubectl logs`** — même observation que Loki, au niveau du pod directement : `GET /healthz HTTP/1.1" 404 Not Found`.

## Cause probable

Faute de frappe dans le chemin de la `readinessProbe` du déploiement `kps-tasks-api-green` : `/healthz` au lieu de `/health` (l'application n'expose que ce dernier). Introduite par le commit `838810a` sur le dépôt GitOps.

## Correctif appliqué

```bash
# apps/kps-tasks-api/deployment-green.yaml : readinessProbe.httpGet.path
# /healthz -> /health
git commit -m "fix(prj8): restore correct readinessProbe path (/health) on green deployment"
git push
```

ArgoCD a resynchronisé automatiquement (rafraîchissement forcé pour accélérer la démo). Le pod cassé a été remplacé par un pod sain, `1/1 Ready`.

## Preuve du retour à la normale

```
kubectl get pods -n kps-tasks
kps-tasks-api-blue-64d479c95d-l7wt2    1/1   Running   0
kps-tasks-api-green-85c47d487d-md8rh   1/1   Running   0
postgres-7777774646-tj2nn              1/1   Running   0
```

`kps-tasks-api-dev` → `Synced` / `Healthy`. Observation complémentaire : l'alerte `KpsTaskApiPodNotReady` est restée visible quelques minutes après la correction, toujours associée au nom du pod supprimé — comportement normal de Prometheus (fenêtre de "staleness" avant qu'une série disparue soit officiellement marquée obsolète), déjà rencontré et documenté au Projet 7. Preuves complètes : [`evidence/alert-triggered.txt`](../evidence/alert-triggered.txt), [`evidence/incident-resolution.txt`](../evidence/incident-resolution.txt).

## Action préventive proposée

Ajouter une étape de validation légère dans le pipeline CI/CD (ou un test de "smoke" sur les manifestes) qui vérifie que les chemins de probes déclarés dans les `Deployment` (`readinessProbe`, `livenessProbe`) correspondent à des routes réellement exposées par l'application — détectable statiquement en croisant les définitions FastAPI (`@app.get(...)`) avec les manifestes Kubernetes, sans même avoir besoin de déployer pour le découvrir.

## Amélioration proposée (supervision)

L'intervalle de 2 minutes (`for: 2m`) avant `firing` a bien fonctionné ici (impact nul), mais un scénario avec impact réel (ex : la même erreur sur `blue`) bénéficierait d'un second seuil plus court (`for: 30s`, `severity: critical`) spécifiquement pour la version qui reçoit le trafic, afin de raccourcir le délai de détection quand l'impact utilisateur est réel.
