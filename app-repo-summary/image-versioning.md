# Synthèse — Versioning des images Docker

Résumé pour la soutenance. Détail complet : [`docs/prj4/image-versioning.md`](https://github.com/Ronaldo-F-dev/devops-prj3/blob/main/docs/prj4/image-versioning.md), [`docs/prj3/versioning.md`](https://github.com/Ronaldo-F-dev/devops-prj3/blob/main/docs/prj3/versioning.md).

## Règle

Chaque image Docker poussée sur le registre (GHCR) porte un tag de version sémantique (`vX.Y.Z`), jamais `latest`. Le tag correspond à un tag Git sur le dépôt applicatif — traçabilité directe entre une version de code et une image.

## Historique des versions

| Tag Git | Usage |
|---|---|
| `v1.0.0` | Première version stable (Projet 3) |
| `v1.1.0` | Référence de départ GitOps (Projet 6) |
| `v1.2.0` | Version `green` actuelle (standby, blue/green) |
| `v1.3.0` | Version `blue` actuelle (active, reçoit le trafic) |

## Pourquoi jamais `latest`

`latest` ne dit rien sur ce qui est réellement déployé — deux déploiements à des moments différents avec le même tag `latest` peuvent pointer vers des images totalement différentes. Un tag figé permet de savoir exactement quel code tourne, de comparer deux versions, et de revenir en arrière de façon fiable (rollback).

## Preuve de fonctionnement

Voir [`evidence/registry-image.txt`](../evidence/registry-image.txt) et [`evidence/app-version.txt`](../evidence/app-version.txt) (capturés au Jour 2 de ce projet).
