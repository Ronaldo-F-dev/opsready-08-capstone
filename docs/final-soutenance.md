# Support de soutenance finale — Projet 8 (OpsReady-08)

Durée totale : 30 à 45 minutes. Posture : consultant DevOps junior face à un client technique (LogiCare Solutions). Ce document est le fil conducteur de la présentation — chaque partie renvoie vers le document détaillé correspondant, mais peut se suivre seule à l'oral.

## Partie 1 — Contexte (5 min)

**Le contexte client** : LogiCare Solutions a modernisé progressivement son processus de déploiement — d'une installation manuelle sur VPS (Projet 1-2) jusqu'à une chaîne complète conteneurisée, testée, versionnée, déployée en GitOps sur Kubernetes et supervisée (Projets 3 à 7). Ce projet consolide et prouve que ce socle technique est réel, pas juste une suite d'exercices isolés.

**Le besoin initial** : personne n'était sûr de la version réellement déployée, les logs se consultaient à la main, aucune alerte n'existait, les incidents étaient détectés trop tard.

**Les limites de la situation de départ** : déploiement manuel = erreurs humaines possibles à chaque étape, aucune traçabilité, aucun rollback fiable.

**La démarche progressive** : CI (Projet 3) → CD vers VPS avec rollback (Projet 4) → migration Kubernetes (Projet 5) → GitOps avec ArgoCD, blue/green (Projet 6) → observabilité complète Prometheus/Grafana/Loki/Alertmanager (Projet 7) → ce projet : consolidation, preuve, Terraform.

**Objectifs atteints** : voir la checklist des critères de réussite en fin de document.

## Partie 2 — Architecture finale (5 min)

Diagramme complet : [`architecture/final-architecture.md`](../architecture/final-architecture.md).

À présenter dans l'ordre : les deux VPS (Kubernetes/application vs CI-CD/outillage), le trajet d'un changement (commit → CI → registre → GitOps → ArgoCD → Kubernetes → observabilité), pourquoi deux dépôts séparés (applicatif vs GitOps), le rôle de chaque composant de la stack d'observabilité.

## Partie 3 — Démonstration de bout en bout (10-15 min)

Répétée et validée au Jour 2 : [`day2-full-demo.md`](day2-full-demo.md).

Déroulé recommandé en live : montrer un changement de code trivial → branche → PR → pipeline CI (tous les jobs, expliquer pourquoi chacun existe) → merge → tag → image dans le registre → mise à jour du tag GitOps sur `green` → ArgoCD détecte et synchronise → rollout vérifié → `/health`/`/version` sur le nouveau pod → visible dans Grafana et Loki.

**Ne pas cacher** : le job `deploy` obsolète qui reste en attente, et l'anomalie `APP_VERSION` trouvée et corrigée en cours de route — les mentionner spontanément renforce la crédibilité plutôt que de la fragiliser.

## Partie 4 — Incident déclenché (10 min)

Le formateur choisit un scénario parmi la liste du brief, inconnu à l'avance. Méthode à appliquer, dans l'ordre, sans dévier : [`diagnostic-checklist.md`](diagnostic-checklist.md).

**Rappel du principe** : ne jamais lancer de commande au hasard. Expliquer à voix haute le raisonnement à chaque étape (« je constate X, donc je vérifie Y, ce qui confirme/infirme Z »). Exemple réel déjà mené comme entraînement (readinessProbe cassée, Jour 3) : [`final-incident-report.md`](final-incident-report.md).

À l'issue : symptôme, impact, hypothèses explorées, outils utilisés, cause probable, correctif, preuve du retour à la normale.

## Partie 5 — Bases Terraform (5 min)

Lab : [`terraform-basics/README.md`](../terraform-basics/README.md).

Montrer en live (ou avec les preuves capturées) : `init` → `plan` → `apply` → `output` → `destroy`. Expliquer sans notes : ce qu'est un provider, une resource, le state (et pourquoi il n'est jamais committé), une variable, un output. Être honnête sur le niveau : "bases comprises, pas une expertise avancée" — c'est exactement ce que le brief demande.

## Partie 6 — Limites et améliorations (5 min)

Liste complète, avec la source précise de chaque limite : [`limitations-and-improvements.md`](limitations-and-improvements.md).

Ne pas lire la liste entière — sélectionner les 3-4 points les plus parlants (ex : job `deploy` obsolète, absence de `requests`/`limits` Kubernetes, pas de notification d'alerte externe) et les développer brièvement plutôt que de survoler tout.

## Questions/Réponses (5-10 min)

Points à avoir en tête, prêts à expliquer sans notes :
- Pourquoi deux dépôts séparés (applicatif / GitOps) ?
- Push vs pull (CI classique vs GitOps) ?
- Comment fonctionne le mécanisme blue/green, et pourquoi cette option plutôt que deux namespaces séparés ([ADR-002](../architecture/adr-summary.md)) ?
- Différence métrique/log, pourquoi les deux sont nécessaires ?
- Terraform vs Ansible, Terraform vs ArgoCD ?
- Toutes les réponses aux questions intermédiaires des Projets 5 à 7 restent valables et consultables : [`docs/prj7/intermediate-questions.md`](https://github.com/Ronaldo-F-dev/devops-prj3/blob/main/docs/prj7/intermediate-questions.md) (Projet 7), [`docs/intermediate-questions.md`](https://github.com/Ronaldo-F-dev/kps-tasks-gitops/blob/main/docs/intermediate-questions.md) (Projet 6).

## Checklist finale des critères de réussite (brief, section 9)

- [x] Architecture cohérente présentée
- [x] Pipeline CI fonctionne (jobs applicatifs verts ; job `deploy` obsolète documenté, pas caché)
- [x] Image Docker construite et poussée (`v1.4.0` vérifiée dans le registre)
- [x] Dépôt GitOps utilisé (aucune modification manuelle du cluster pour un changement applicatif)
- [x] ArgoCD synchronise l'application (`Synced`/`Healthy` vérifié à chaque étape)
- [x] Application déployée sur Kubernetes
- [x] Application observable dans Grafana
- [x] Logs consultables dans Loki
- [x] Au moins une alerte visible/démontrable (`KpsTaskApiHighCPU` déclenchée réellement, Projet 7 ; `KpsTaskApiPodNotReady` déclenchée réellement, Projet 8 Jour 3)
- [x] Incident diagnostiqué (readinessProbe cassée, méthode complète appliquée)
- [x] Correctif proposé et appliqué
- [x] Rapport d'incident produit (`docs/final-incident-report.md`)
- [x] Mini-lab Terraform exécuté (`init`/`plan`/`apply`/`output`/`destroy`)
- [x] Terraform expliqué sans surestimer le niveau
- [x] Limites du projet clairement identifiées
