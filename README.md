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

### Checklist des 10 tâches du brief

| # | Tâche | Vérification effectuée |
|---|---|---|
| 1 | Vérifier le dépôt applicatif | `git status` propre après correction (voir ci-dessous) ; code, `Dockerfile`, tests, pipeline CI, `.env.example`, `CHANGELOG.md`, `README.md` tous présents |
| 2 | Vérifier le dépôt GitOps | `git status` propre ; manifestes blue/green cohérents avec l'état réellement déployé |
| 3 | Vérifier le pipeline CI | `.github/workflows/ci.yml` présent, jobs `lint`/`test`/`secret_scan`/`sonar`/`docker_build` fonctionnels (revérifié en conditions réelles au Jour 2) ; doc CI existante ([`docs/prj3/ci-pipeline.md`](https://github.com/Ronaldo-F-dev/devops-prj3/blob/main/docs/prj3/ci-pipeline.md)) et job `deploy` documenté séparément ([`docs/prj4/deployment-process.md`](https://github.com/Ronaldo-F-dev/devops-prj3/blob/main/docs/prj4/deployment-process.md)) |
| 4 | Vérifier les tags d'image | Jamais `latest` : `v1.2.0` (green), `v1.3.0` (blue) au moment du Jour 1 |
| 5 | Vérifier les manifestes Kubernetes | `deployment-blue.yaml`/`deployment-green.yaml`/`app-service.yaml`/`postgres-*.yaml` présents et cohérents |
| 6 | Vérifier ArgoCD | Voir détail ci-dessous |
| 7 | Vérifier les dashboards Grafana | 2 dashboards (infra + application) toujours présents, Grafana accessible (HTTP 200) |
| 8 | Vérifier Loki | Voir détail ci-dessous |
| 9 | Vérifier les règles d'alerte | 4 `PrometheusRule` chargées (`pod-alerts`, `app-alerts`, `resource-alerts`), toutes `health: ok` |
| 10 | Finaliser la documentation globale | Ce README + résumés `app-repo-summary/`, `gitops-repo-summary/`, `observability/`, `architecture/` |

### Ce qui a été trouvé et corrigé (pas juste "tout est vert")

- **Dépôt applicatif** : 3 fichiers avaient des modifications non committées corrompues (texte mélangé de façon incohérente, pas des changements volontaires) — annulées (`git restore`). `.vscode/` et le fichier de notes personnelles `note.txt` ajoutés au `.gitignore`.
- **`CHANGELOG.md` incomplet** : ne contenait qu'une entrée `v1.0.0`, alors que 4 tags supplémentaires existaient (`v1.1.0` → `v1.4.0`) sans jamais avoir été documentés. Corrigé avec une entrée par version, reconstruite depuis `git log` entre chaque tag.
- **Aucun secret réel exposé** dans les 3 dépôts (recherche de motifs `password`/`secret` en dur — rien trouvé hors fichiers `.example`).

### Vérification détaillée — ArgoCD (tâche 6)

```
kubectl get application kps-tasks-api-dev -n argocd -o jsonpath=...
Namespace cible : kps-tasks
Dépôt source    : https://github.com/Ronaldo-F-dev/kps-tasks-gitops.git
Chemin          : apps/kps-tasks-api
Sync policy     : automated
Sync status     : Synced
Health status   : Healthy
Revision        : correspond exactement au dernier commit du dépôt GitOps (vérifié avec `git log -1`)
```

Les 7 pods `argocd-*` sont `Running`. La révision suivie par ArgoCD correspond bit à bit au commit `HEAD` du dépôt GitOps — confirmation qu'ArgoCD ne suit pas un état périmé.

### Vérification détaillée — Loki (tâche 8)

```
kubectl get pods -n monitoring -l app=loki        -> loki-0 Running
kubectl get pods -n monitoring -l app.kubernetes.io/name=promtail  -> loki-promtail-<hash> Running
```

Namespaces couverts (`/loki/api/v1/label/namespace/values`) : `argocd`, `kps-tasks`, `kube-system`, `monitoring` — toutes les sources attendues. Test de bout en bout : une requête `GET /health` envoyée à l'application, retrouvée dans Loki en moins de 10 secondes. Source de données Loki confirmée dans Grafana (`type: loki`, `url: http://loki:3100`), aux côtés de Prometheus et Alertmanager.

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

## Jour 3 — Incident déclenché et diagnostic structuré (terminé)

**Scénario choisi** (parmi la liste du brief) : **readinessProbe cassée**, sur `green` (standby, sans impact utilisateur) — volontairement différent de l'incident du Projet 7 (tag d'image invalide) pour couvrir un mode de panne distinct : un pod `Running` qui n'est jamais `Ready`, sans jamais redémarrer.

**Déroulé** : chemin de la `readinessProbe` changé de `/health` vers `/healthz` (inexistant) dans le dépôt GitOps → ArgoCD synchronise → nouveau pod `green` bloqué `0/1 Ready`, `0` redémarrage.

**Méthode de diagnostic suivie, dans l'ordre, sans commande au hasard** :
1. Dashboard application (Grafana/Prometheus) → `kube_pod_status_ready{condition="false"}` confirmé
2. Alertmanager/règles → `KpsTaskApiPodNotReady` `pending` puis `firing` (2 min, conforme au seuil)
3. **Logs Loki (élément décisif)** → requêtes répétées `GET /healthz -> 404` toutes les ~10s, alors que `GET /` (liveness) répond `200` — isole immédiatement la cause
4. ArgoCD → `Synced` (vient de Git) / `Progressing` (bloqué)
5. `kubectl describe pod` → confirmation explicite : `Readiness probe failed: HTTP probe failed with statuscode: 404`
6. `kubectl logs` → même confirmation au niveau du pod

**Cause** : faute de frappe sur le chemin de la probe (`/healthz` au lieu de `/health`). **Correctif** : commit GitOps d'une ligne, resynchronisation, retour à la normale vérifié (`Synced`/`Healthy`, pod sain, 0 redémarrage). **Impact réel** : aucun (`blue` jamais affecté).

Rapport complet et structuré : [`docs/final-incident-report.md`](docs/final-incident-report.md). Méthode générale réutilisable : [`observability/incident-diagnostic.md`](observability/incident-diagnostic.md). Preuves : [`evidence/alert-triggered.txt`](evidence/alert-triggered.txt), [`evidence/incident-resolution.txt`](evidence/incident-resolution.txt).

### Jour 3 — Résultat

Incident réel, diagnostiqué avec méthode complète (dashboards → alertes → logs → ArgoCD → kubectl), corrigé, documenté. **Prêt pour le Jour 4** (mini-lab Terraform).

---

## Jour 4 — Mini-lab Terraform obligatoire (terminé)

**Avertissement assumé** (demandé par le brief) : ce lab couvre les bases de Terraform, pas une expertise. Objectif : pouvoir en parler honnêtement en entretien.

Lab dans [`terraform-basics/`](terraform-basics/) — provider [`kreuzwerker/docker`](https://registry.terraform.io/providers/kreuzwerker/docker/latest), crée un conteneur Nginx :

```bash
terraform init      # telecharge le provider Docker
terraform plan       # 2 ressources a creer (image + conteneur)
terraform apply       # cree reellement le conteneur
terraform output       # http://localhost:8090
curl http://localhost:8090   # -> HTTP 200, verifie hors Terraform
terraform destroy       # supprime tout
```

Toutes les commandes exécutées pour de vrai (pas seulement documentées) : `init` → `plan` → `apply` → `output` → vérification HTTP indépendante → nouveau `plan` confirmant `No changes` (idempotence) → `destroy` → conteneur bien disparu (`docker ps` vide, connexion refusée).

**Concepts expliqués** (IaC, provider, resource, state, variable, output, cycle init/plan/apply/destroy, Terraform vs Ansible, Terraform vs ArgoCD) : [`terraform-basics/README.md`](terraform-basics/README.md).

**Sécurité** : `terraform.tfstate` jamais committé (`.gitignore`), rôle et contenu sensible du state expliqués. Un oubli initial corrigé en cours de route : le fichier de plan (`tfplan`) n'était pas dans `.gitignore` — ajouté, car un plan peut aussi exposer des valeurs sensibles.

Preuves : [`evidence/terraform-init.txt`](evidence/terraform-init.txt), [`evidence/terraform-plan.txt`](evidence/terraform-plan.txt), [`evidence/terraform-apply.txt`](evidence/terraform-apply.txt), [`evidence/terraform-destroy.txt`](evidence/terraform-destroy.txt).

### Jour 4 — Résultat

Mini-lab exécuté de bout en bout, concepts expliqués honnêtement, aucun state committé. **Prêt pour le Jour 5** (soutenance finale).

---
