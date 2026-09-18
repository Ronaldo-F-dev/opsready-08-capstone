# Synthèse — Blue/green

Résumé pour la soutenance. Détail complet : [`docs/blue-green-deployment.md`](https://github.com/Ronaldo-F-dev/kps-tasks-gitops/blob/main/docs/blue-green-deployment.md), [`ADR-002`](https://github.com/Ronaldo-F-dev/kps-tasks-gitops/blob/main/docs/adr/ADR-002-blue-green-strategy.md).

## Mécanisme

Deux `Deployment` distincts (`kps-tasks-api-blue`, `kps-tasks-api-green`) tournent en parallèle dans le même namespace, chacun avec sa propre version d'image. Un seul `Service` route le trafic, via son sélecteur (`version: blue` ou `version: green`) — changer le sélecteur bascule instantanément le trafic d'une version à l'autre, sans interruption.

## État actuel (vérifié Jour 1 du Projet 8)

- `blue` → image `v1.3.0`, **actif** (le Service pointe sur `version: blue`)
- `green` → image `v1.2.0`, standby

## Pourquoi cette stratégie

Permet de déployer une nouvelle version sans jamais interrompre le service : la nouvelle version démarre en standby, est vérifiée, puis le trafic bascule seulement quand elle est prête. En cas de problème après bascule, revenir à l'ancienne version est instantané (re-basculer le sélecteur), bien plus rapide qu'un rollback complet.

## Limite assumée

Deux fois plus de ressources consommées en permanence (deux versions tournent simultanément), acceptable ici car l'application est très légère.
