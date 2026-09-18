# Synthèse — Rollback GitOps

Résumé pour la soutenance. Détail complet : [`docs/rollback-gitops.md`](https://github.com/Ronaldo-F-dev/kps-tasks-gitops/blob/main/docs/rollback-gitops.md).

## Principe

En GitOps, un rollback n'est pas une commande Kubernetes spéciale — c'est un commit Git. Revenir à une version antérieure = remettre l'ancien tag d'image dans le manifeste, committer, pousser. ArgoCD synchronise et le cluster revient à l'état précédent, exactement comme n'importe quel autre changement.

## Deux façons de "revenir en arrière" dans ce projet

1. **Rollback GitOps classique** : revert du tag d'image dans le dépôt GitOps (démontré lors de l'incident du Projet 7, Jour 5 — tag invalide sur `green`, corrigé par un commit).
2. **Bascule blue/green** : re-pointer le sélecteur du Service vers l'ancienne version, encore plus rapide qu'un rollback GitOps classique car aucune image à re-pull, l'ancienne version tourne déjà.

## Pourquoi le documenter clairement

En soutenance, savoir expliquer *comment* revenir en arrière est aussi important que savoir avancer — le brief du Projet 8 demande explicitement de "présenter une stratégie de rollback" et de produire une `rollback-checklist.md`.
