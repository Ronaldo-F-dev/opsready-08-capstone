# Synthèse — Application ArgoCD

Résumé pour la soutenance. Détail complet : [`docs/argocd-installation.md`](https://github.com/Ronaldo-F-dev/kps-tasks-gitops/blob/main/docs/argocd-installation.md), [`docs/argocd-application.md`](https://github.com/Ronaldo-F-dev/kps-tasks-gitops/blob/main/docs/argocd-application.md), [`docs/gitops-principles.md`](https://github.com/Ronaldo-F-dev/kps-tasks-gitops/blob/main/docs/gitops-principles.md).

## Principe GitOps

Avant ArgoCD (Projet 5) : déploiement manuel (`kubectl apply`), personne n'est sûr de la version réellement en place. Avec ArgoCD (Projet 6) : **Git devient la seule source de vérité**. ArgoCD surveille en permanence le dépôt `kps-tasks-gitops` et synchronise le cluster avec ce qu'il y trouve — un commit devient le seul geste de déploiement.

## Application

- Nom : `kps-tasks-api-dev`
- Namespace cible : `kps-tasks`
- Synchronisation automatique activée (`syncPolicy.automated`)
- Interface : `https://<IP-VPS>:30843`

## État vérifié (Jour 1 du Projet 8)

`kubectl get application kps-tasks-api-dev -n argocd` → `Synced` / `Healthy`. Preuve : [`evidence/argocd-synced-healthy.txt`](../evidence/argocd-synced-healthy.txt).
