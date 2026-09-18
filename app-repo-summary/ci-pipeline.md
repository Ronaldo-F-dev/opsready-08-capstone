# Synthèse — Pipeline CI (dépôt applicatif)

Résumé pour la soutenance. Détail complet : [`docs/prj3/ci-pipeline.md`](https://github.com/Ronaldo-F-dev/devops-prj3/blob/main/docs/prj3/ci-pipeline.md), [`docs/prj4/cicd-architecture.md`](https://github.com/Ronaldo-F-dev/devops-prj3/blob/main/docs/prj4/cicd-architecture.md), workflow : [`.github/workflows/ci.yml`](https://github.com/Ronaldo-F-dev/devops-prj3/blob/main/.github/workflows/ci.yml).

## Ce que fait le pipeline

Déclenché sur push/merge request. Étapes dans l'ordre :
1. **Lint** — qualité du code Python
2. **Tests** — suite de tests automatisés
3. **Gitleaks** — scan de secrets dans le code et l'historique
4. **SonarCloud** — analyse statique (bugs, vulnérabilités, code smells, duplication, couverture)
5. **Build** de l'image Docker
6. **Push** de l'image vers le registre (GHCR)

## Pourquoi cet ordre

Chaque étape agit comme une porte : inutile de construire une image Docker (coûteux en temps) si le code ne passe même pas le lint ou les tests. Gitleaks et SonarCloud interviennent avant le build pour bloquer un secret ou une vulnérabilité avant qu'elle ne soit figée dans une image versionnée et publiée.

## Preuve de fonctionnement

Voir [`evidence/pipeline-green.txt`](../evidence/pipeline-green.txt) (capturé au Jour 2 de ce projet).
