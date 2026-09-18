# Projet 8 — OpsReady-08 : Capstone final

**Ce document est LE fil conducteur de la soutenance finale.** Même principe que le Projet 7 (leçon retenue après le Projet 6) : tout est construit ici jour après jour, jamais assemblé à la fin, pour ne jamais se perdre entre plusieurs sources pendant la présentation.

Ce projet **ne réécrit rien** : il consolide, démontre, documente et défend tout ce qui a été construit dans les Projets 1 à 7. Trois dépôts au total :

| Dépôt | Contenu | Lien |
|---|---|---|
| [`devops-prj3`](https://github.com/Ronaldo-F-dev/devops-prj3) | Code applicatif, Dockerfile, pipeline CI, monitoring (Prometheus/Grafana/Loki), Terraform | dépôt existant |
| [`kps-tasks-gitops`](https://github.com/Ronaldo-F-dev/kps-tasks-gitops) | Manifestes Kubernetes, blue/green, configuration ArgoCD | dépôt existant |
| `opsready-08-capstone` (celui-ci) | Synthèse finale : architecture, résumés des deux dépôts, mini-lab Terraform, incident final, support de soutenance | nouveau, dédié au Projet 8 |

## Structure de ce dépôt

- `architecture/` — diagramme et description de l'architecture finale
- `app-repo-summary/` — synthèse du dépôt applicatif (CI/CD, versioning d'image, qualité/sécurité)
- `gitops-repo-summary/` — synthèse du dépôt GitOps (ArgoCD, sync/drift, blue/green, rollback)
- `observability/` — synthèse Grafana/Loki/Alertmanager, diagnostic
- `terraform-basics/` — mini-lab Terraform obligatoire (provider Docker)
- `docs/` — rapport d'incident final, support de soutenance, limites/améliorations, checklists
- `evidence/` — preuves capturées pendant la consolidation et la démo

---

## Jour 1 — Consolidation finale des dépôts et de la documentation (terminé)

### Objectif du jour

Nettoyer, structurer et finaliser les dépôts avant la soutenance — pas de nouveau code, juste vérifier que tout ce qui a été construit depuis le Projet 1 tient encore debout et est présentable.

### Ce qui a été vérifié

- **Dépôt applicatif propre** : 3 fichiers avaient des modifications non committées corrompues (texte mélangé de façon incohérente, pas des changements volontaires) — annulées (`git restore`). `.vscode/` et le fichier de notes personnelles `note.txt` ajoutés au `.gitignore`.
- **Dépôt GitOps propre** : `git status` vide, tags d'image jamais `latest` (`v1.2.0` sur `green`, `v1.3.0` sur `blue`, cohérent avec l'état réellement déployé).
- **Pipeline CI** : présent et fonctionnel (`.github/workflows/ci.yml`).
- **ArgoCD** : `kps-tasks-api-dev` → `Synced` / `Healthy`.
- **Dashboards Grafana, Loki, règles d'alerte** : toujours en place et opérationnels (4 `PrometheusRule` chargées, Loki/Promtail `Running`).
- **Accès externe** : application, Grafana, Prometheus, Alertmanager, ArgoCD tous accessibles (HTTP 200/302 selon l'endpoint).
- **Aucun secret réel exposé** dans les 3 dépôts (recherche de motifs `password`/`secret` en dur — rien trouvé hors fichiers `.example`).

Documentation de synthèse écrite : [`architecture/final-architecture.md`](architecture/final-architecture.md), [`app-repo-summary/`](app-repo-summary/) (CI, versioning, sécurité/qualité), [`gitops-repo-summary/`](gitops-repo-summary/) (ArgoCD, sync/drift, blue/green, rollback), [`observability/`](observability/) (dashboards, Loki, alertes). Preuve de l'état stable : [`evidence/platform-stable-state.txt`](evidence/platform-stable-state.txt).

### Jour 1 — Résultat

Les deux dépôts existants sont propres et l'infrastructure entière est saine. Documentation de synthèse en place. **Prêt pour le Jour 2** (répétition de la démo complète de bout en bout).

---

## Jour 2 — Démonstration complète de la chaîne DevOps (terminé)

Changement réel dérouled de bout en bout : ajout d'un champ `uptime_seconds` à `GET /health`.

**Flux suivi** : branche → commit (`feat: report uptime_seconds in /health response`) → [PR #7](https://github.com/Ronaldo-F-dev/devops-prj3/pull/7) → pipeline CI vert (Gitleaks, lint, test, SonarCloud, build+push) → merge sur `main` → tag `v1.4.0` → image publiée sur le registre → tag mis à jour dans le dépôt GitOps (`deployment-green.yaml`, version standby, `blue` non affecté) → ArgoCD détecte et synchronise (`Synced`/`Healthy`) → rollout vérifié → `/health` du nouveau pod confirme `uptime_seconds` et `version: "1.4.0"` → visible dans Grafana (Prometheus) et Loki.

**Deux découvertes réelles en cours de route** (pas seulement des commandes qui marchent du premier coup) :
1. Le job CI `deploy` (héritage Projet 4, Docker Compose via SSH) reste bloqué en attente à chaque push sur `main` — obsolète depuis Kubernetes/ArgoCD, volontairement laissé tel quel, à expliquer en soutenance plutôt qu'à cacher.
2. `blue` (version active) affichait `/version: "1.1.0"` alors que son image était déjà `v1.3.0` — variable d'environnement `APP_VERSION` désynchronisée par une mise à jour précédente. Corrigée par un commit GitOps d'une ligne, resynchronisée, vérifiée.

Détail complet, étape par étape, avec le *pourquoi* de chaque choix : [`docs/day2-full-demo.md`](docs/day2-full-demo.md). Preuves : [`evidence/pipeline-green.txt`](evidence/pipeline-green.txt), [`evidence/registry-image.txt`](evidence/registry-image.txt), [`evidence/argocd-synced-healthy.txt`](evidence/argocd-synced-healthy.txt), [`evidence/app-version.txt`](evidence/app-version.txt), [`evidence/grafana-dashboard.txt`](evidence/grafana-dashboard.txt), [`evidence/loki-logs.txt`](evidence/loki-logs.txt).

### Jour 2 — Résultat

Chaîne complète démontrée sans aucune intervention manuelle sur Kubernetes (hors rafraîchissement ArgoCD, purement pour accélérer la démo). **Prêt pour le Jour 3** (incident déclenché et diagnostic structuré).

---
