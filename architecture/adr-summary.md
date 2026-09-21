# ADR principaux — synthèse

Ce projet ne réécrit aucune décision déjà actée — ce document liste et résume les ADR ("Architecture Decision Record") produits pendant le parcours, pour qu'ils soient trouvables depuis ce dépôt de synthèse.

## ADR-002 — Stratégie de déploiement blue/green

Dépôt source : [`kps-tasks-gitops/docs/adr/ADR-002-blue-green-strategy.md`](https://github.com/Ronaldo-F-dev/kps-tasks-gitops/blob/main/docs/adr/ADR-002-blue-green-strategy.md)

**Décision** : deux `Deployment` (`kps-tasks-api-blue`/`-green`) dans le même namespace, un seul `Service` dont le sélecteur choisit la version active — plutôt que deux namespaces séparés.

**Pourquoi cette option** : la bascule se résume à un seul changement dans un seul fichier Git (`app-service.yaml`), facile à auditer et à expliquer. Compromis assumé : les deux versions partagent la même base PostgreSQL — un risque réel uniquement en cas de migration de schéma incompatible entre les deux versions (non rencontré dans ce projet).

## Pourquoi un seul ADR formel dans ce parcours

La plupart des autres décisions structurantes (registre GHCR, GitOps avec ArgoCD, Prometheus/Grafana/Loki comme stack d'observabilité) ont été prises dès le départ par le brief de chaque projet — un ADR documente un choix fait *parmi plusieurs options réellement envisagées*, pas une contrainte imposée sans alternative. Le choix blue/green (option A vs option B, namespace partagé vs séparé) est le seul point du parcours où une vraie alternative architecturale a été pesée et tranchée.
