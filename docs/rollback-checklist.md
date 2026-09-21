# Checklist de rollback

Deux mécanismes distincts, selon la situation. Voir [`gitops-repo-summary/rollback-gitops.md`](../gitops-repo-summary/rollback-gitops.md) pour le détail.

## Option 1 — Bascule blue/green (la plus rapide)

À utiliser si l'ancienne version tourne encore (standby) et qu'un problème est détecté juste après une bascule vers la nouvelle version.

- [ ] Confirmer que l'ancienne version (ex : `blue`) est toujours `Running`/`Ready` — ne jamais basculer vers une version qu'on n'a pas vérifiée
- [ ] Modifier le sélecteur du `Service` dans le dépôt GitOps pour repointer vers l'ancienne version
- [ ] Commit + push (jamais de `kubectl patch` manuel sur le cluster)
- [ ] ArgoCD synchronise, `Synced`/`Healthy`
- [ ] Vérifier `/health` et `/version` via le Service public — confirme le retour à l'ancienne version
- [ ] Documenter pourquoi la bascule a eu lieu (même succincte) avant de passer à autre chose

## Option 2 — Rollback GitOps classique (revert de tag)

À utiliser si aucune version saine ne tourne déjà en standby (ex : les deux versions sont sur la même image cassée, ou l'incident concerne autre chose qu'une version d'image).

- [ ] Identifier le dernier tag d'image connu comme sain (`git log`, `CHANGELOG.md`)
- [ ] Modifier le tag d'image dans le manifeste GitOps concerné, revenir à ce tag connu
- [ ] Commit + push
- [ ] ArgoCD synchronise, `Synced`/`Healthy`
- [ ] Vérifier le rollout (pod `Running`/`Ready`, `/health`/`/version` cohérents avec la version restaurée)

## Ce qu'on ne fait jamais

- Modifier Kubernetes directement (`kubectl edit`, `kubectl patch`) pour un rollback applicatif courant — toujours via un commit Git, sauf scénario de diagnostic explicitement autorisé
- Rollback sans avoir d'abord confirmé la cause (un rollback qui ne corrige pas la vraie cause ne fait que repousser le problème)

## Preuve que ça marche réellement

Démontré au Projet 7 (Jour 5) et au Projet 8 (Jour 3) : dans les deux cas, un tag/chemin invalide poussé par erreur en GitOps a été corrigé par un simple commit de retour arrière, resynchronisé par ArgoCD, sans jamais toucher au cluster directement.
