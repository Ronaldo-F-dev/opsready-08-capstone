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
