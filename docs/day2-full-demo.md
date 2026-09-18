# Jour 2 — Démonstration complète de la chaîne DevOps

Document détaillé du Jour 2. Résumé condensé dans [`README.md`](../README.md). Chaque étape ci-dessous suit exactement le flux attendu par le brief (tâches 11-27) : `commit → build → registry → GitOps → ArgoCD → Kubernetes → observabilité`.

## Objectif du jour

Répéter et valider la démonstration complète avant la soutenance finale — pas en enchaînant des commandes mécaniquement, mais en expliquant à chaque étape ce qu'elle apporte, quel risque elle réduit, et quelle preuve elle fournit.

## Le changement choisi

Ajout d'un champ `uptime_seconds` à la réponse de `GET /health`, calculé depuis le démarrage du processus (`time.monotonic() - _started_at`). Changement volontairement petit et sûr — l'objectif du jour est de prouver la chaîne, pas de livrer une fonctionnalité complexe.

**Pourquoi ce choix** : un champ nouveau, visible et testable en une requête HTTP, permet de vérifier concrètement "la nouvelle version tourne" à chaque étape (build, rollout, accès direct au pod) sans ambiguïté.

## Étape par étape

### 1-3. Branche, changement, commit (tâches 11-13)

```bash
git checkout -b feat/health-uptime
# app/main.py, app/schemas.py, tests/test_api.py modifiés
git commit -m "feat: report uptime_seconds in /health response"
```

Un test a été ajouté (`test_health_reports_uptime`) et volontairement écrit pour accepter `200` **ou** `503` — le endpoint `/health` renvoie `503` si la base est injoignable, ce qui est un comportement voulu (pas un bug). Un test qui n'exigerait que `200` casserait dès que l'environnement de test n'a pas de PostgreSQL disponible, pour une mauvaise raison.

**Ce que ça réduit comme risque** : travailler sur une branche isole le changement du code déjà en production (`main`) jusqu'à validation complète.

### 4. Merge Request / Pull Request (tâche 14)

[PR #7](https://github.com/Ronaldo-F-dev/devops-prj3/pull/7) ouverte sur le dépôt applicatif. **Pourquoi une PR et pas un push direct sur `main`** : force le passage par le pipeline CI complet avant toute fusion, et laisse une trace de revue même en travail individuel.

### 5-6. Pipeline CI, scan qualité et sécurité (tâches 15-16)

Sur la PR (déclenchement `pull_request`), tous les jobs passent : `Gitleaks` (secrets), `lint`, `test`, `SonarCloud` (qualité/sécurité statique), `Build and push Docker image`. Le job `Deploy to VPS` (héritage Projet 4, déploiement Docker Compose direct) est correctement **ignoré** sur une PR — sa condition (`if: github.ref == 'refs/heads/main'`) ne le déclenche que sur `main`.

**Limite connue à expliquer en soutenance** : ce job `deploy` reste bloqué en attente sur chaque push vers `main` (probablement une "environment protection rule" GitHub jamais approuvée) — c'est un vestige de l'architecture du Projet 4 (déploiement Docker Compose via SSH), remplacé depuis par Kubernetes + ArgoCD (Projets 5-7). Il n'a pas été supprimé pour ce projet (décision du porteur du projet), donc le pipeline reste visuellement "en attente" sur ce job précis à chaque push sur `main` — les jobs qui comptent réellement pour cette chaîne (lint/test/scan/build/push) sont tous verts. Preuve : [`evidence/pipeline-green.txt`](../evidence/pipeline-green.txt).

### 7. Build de l'image Docker (tâche 17)

Fait automatiquement par le job `docker_build` du pipeline — image taguée `commit-<sha>` systématiquement, plus un tag de version (`vX.Y.Z`) uniquement si le déclencheur est un tag Git.

### 8. Push vers le registry (tâche 18)

```bash
git tag -a v1.4.0 -m "v1.4.0: /health reports uptime_seconds"
git push origin v1.4.0
```

Pousser le tag déclenche une seconde exécution du pipeline (déclencheur `tags: v*`), qui construit et pousse cette fois l'image versionnée `ghcr.io/ronaldo-f-dev/kps-tasks-api:v1.4.0`. Vérifié avec `docker manifest inspect` — preuve : [`evidence/registry-image.txt`](../evidence/registry-image.txt).

**Pourquoi séparer le merge (main) et le tag** : permet de fusionner du code sans forcément publier une version — le tag est un acte délibéré, distinct du simple fait d'intégrer du code à `main`.

### 9-10. Mise à jour du tag dans le dépôt GitOps, détection par ArgoCD (tâches 19-20)

Le tag d'image a été mis à jour sur `deployment-green.yaml` (version standby, pas `blue` qui sert le trafic réel) :

```bash
# apps/kps-tasks-api/deployment-green.yaml : v1.2.0 -> v1.4.0
git commit -m "feat: update green deployment to v1.4.0 (adds /health uptime_seconds)"
git push
```

**Pourquoi `green` et pas `blue`** : `green` est actuellement la version standby (le Service route vers `blue`). Mettre à jour `green` permet de démontrer tout le flux GitOps → ArgoCD → Kubernetes sans jamais risquer d'interrompre le trafic réel — exactement l'intérêt du mécanisme blue/green (Projet 6).

ArgoCD a détecté le changement après un rafraîchissement forcé (`kubectl annotate ... argocd.argoproj.io/refresh=hard`) — en usage normal, la détection est automatique dans les minutes suivant le push (polling périodique du dépôt Git).

### 11-12. Synchronisation Kubernetes, vérification du rollout (tâches 21-22)

```
kps-tasks-api-green-85c47d487d-md8rh   1/1   Running   0
image: ghcr.io/ronaldo-f-dev/kps-tasks-api:v1.4.0
```

`kubectl get application kps-tasks-api-dev -n argocd` → `Synced` / `Healthy`. Preuve : [`evidence/argocd-synced-healthy.txt`](../evidence/argocd-synced-healthy.txt).

### 13-14. Vérifier /health et /version (tâches 23-24)

Requête directe sur le nouveau pod `green` (`kubectl exec ... curl localhost:8000/health`, sans passer par le Service puisque `green` n'est pas encore actif) :

```json
{"status": "ok", "database": "ok", "version": "1.4.0", "uptime_seconds": 23.88, "details": null}
```

Le champ `uptime_seconds` est bien présent — preuve directe que le nouveau code tourne. Preuve complète : [`evidence/app-version.txt`](../evidence/app-version.txt).

**Découverte annexe et correction** : en vérifiant `/version` sur `blue` (la version réellement active), le champ `version` affichait `"1.1.0"` alors que l'image déployée était déjà `v1.3.0` — un résidu d'une mise à jour antérieure où le tag d'image avait été changé sans mettre à jour la variable d'environnement `APP_VERSION` en même temps. Corrigé par un commit GitOps d'une ligne (`fix: align APP_VERSION with the actually deployed image tag`), resynchronisé, vérifié : `/version` via le Service actif renvoie maintenant correctement `"1.3.0"`.

**Pourquoi cette anomalie est intéressante à mentionner en soutenance** : elle illustre concrètement pourquoi GitOps ne suffit pas à lui seul à garantir la cohérence — un déploiement peut être `Synced`/`Healthy` du point de vue d'ArgoCD tout en affichant une information applicative incohérente si le manifeste lui-même contient une valeur figée obsolète. Une vérification fonctionnelle (`/version`) reste nécessaire en complément de l'état GitOps.

### 15-17. Vérifier Grafana, Loki, Alertmanager (tâches 25-27)

- **Grafana/Prometheus** : `kube_pod_info{pod=~"kps-tasks-api-green.*"}` renvoie bien le nouveau pod. Preuve : [`evidence/grafana-dashboard.txt`](../evidence/grafana-dashboard.txt).
- **Loki** : logs applicatifs du nouveau pod visibles quelques secondes après son démarrage (`GET /health -> 200`). Preuve : [`evidence/loki-logs.txt`](../evidence/loki-logs.txt).
- **Alertmanager** : toujours actif et interrogeable pendant toute l'opération, aucune alerte parasite déclenchée par ce déploiement contrôlé.

## Ce que cette répétition démontre

Toute la chaîne fonctionne de bout en bout, sans aucune intervention manuelle sur Kubernetes (seule exception : le rafraîchissement forcé d'ArgoCD, qui accélère simplement une détection qui se serait produite automatiquement en quelques minutes) — conforme à la contrainte du brief "ne pas modifier Kubernetes directement, sauf pour un scénario de diagnostic ou de drift contrôlé".

## Résultat du jour

- Changement réel développé, testé, mergé, taggé, buildé, publié, déployé via GitOps, vérifié fonctionnellement et dans l'observabilité
- Une anomalie réelle trouvée et corrigée en cours de route (`APP_VERSION` désynchronisé)
- Limite connue documentée (job `deploy` obsolète, bloqué en attente)
- **Prêt pour le Jour 3** (incident déclenché et diagnostic structuré).
