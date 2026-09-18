# Synthèse — Synchronisation et drift

Résumé pour la soutenance. Détail complet : [`docs/sync-and-drift.md`](https://github.com/Ronaldo-F-dev/kps-tasks-gitops/blob/main/docs/sync-and-drift.md).

## Push vs pull

- **Push** (Projet 4, CI classique) : le pipeline CI pousse activement les changements vers le cluster.
- **Pull** (GitOps, ArgoCD) : ArgoCD observe Git et applique lui-même les changements, à son rythme. Le cluster ne reçoit jamais de commande externe pour un changement applicatif courant.

## Drift

Un "drift" est un écart entre ce que dit Git et ce qui tourne réellement dans le cluster (ex : quelqu'un modifie une ressource directement avec `kubectl edit`). ArgoCD détecte ce drift (`OutOfSync`) et peut le corriger automatiquement (sync automatisée) ou le signaler pour action manuelle.

**Démontré au Projet 6** : drift provoqué volontairement (`kubectl scale`), détecté (`argocd app diff`), corrigé depuis Git.

**Contrainte du Projet 8** : ne jamais modifier Kubernetes directement, sauf pour un scénario de diagnostic ou de drift contrôlé — exactement ce cadre.
