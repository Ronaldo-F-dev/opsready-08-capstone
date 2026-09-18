# Synthèse — Sécurité et qualité (Gitleaks, SonarCloud)

Résumé pour la soutenance. Détail complet : [`docs/prj3/security-and-quality.md`](https://github.com/Ronaldo-F-dev/devops-prj3/blob/main/docs/prj3/security-and-quality.md).

## Gitleaks

Scanne le code et l'historique Git à chaque exécution du pipeline pour détecter des secrets committés par erreur (clés API, mots de passe, tokens). Bloque le pipeline si un secret est trouvé.

## SonarCloud

Analyse statique du code à chaque pipeline : bugs potentiels, vulnérabilités, "code smells" (mauvaises pratiques), duplication, couverture de tests.

## Limite connue, assumée

Le Quality Gate SonarCloud est en échec sur des vulnérabilités liées à des dépendances non verrouillées à une version exacte dans `requirements.txt` (opérateurs `>=`/`<`) — identifié et volontairement laissé de côté (nécessiterait un fichier de lock, jugé hors périmètre pour ce projet pédagogique). La couverture de tests reste minimale (un seul test, sur l'endpoint racine) : le rapport est fonctionnel mais peu représentatif.

**Pourquoi le dire clairement en soutenance** : présenter une limite connue et expliquée est plus crédible, pour un consultant junior, que de laisser croire que tout est parfait. Le brief du Projet 8 demande explicitement d'identifier les limites du projet plutôt que de les cacher.

## Règle sur les secrets (tout le projet)

Aucun secret réel n'est jamais committé dans un dépôt Git. Les mots de passe (Grafana, ArgoCD, PostgreSQL) sont générés côté serveur et stockés uniquement sur le VPS — jamais affichés dans un terminal partagé, jamais dans l'historique Git. Les dépôts ne contiennent que des fichiers `.example` (`.env.example`, `*-secret.example.yaml`).
