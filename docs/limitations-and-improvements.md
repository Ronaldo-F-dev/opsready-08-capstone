# Limites et améliorations

Consolidation honnête de tout ce qui a été trouvé pendant le parcours — pas une liste générique, mais les limites réellement rencontrées et documentées à chaque étape.

## Limites connues, déjà rencontrées et documentées

| Limite | Où elle a été trouvée | Pourquoi elle a été laissée telle quelle |
|---|---|---|
| Job CI `deploy` (Docker Compose/SSH) reste bloqué en attente sur chaque push `main` | Projet 8, Jour 2 | Héritage du Projet 4, remplacé par Kubernetes/ArgoCD depuis le Projet 5 — supprimer un job CI en place n'était pas jugé prioritaire pour ce parcours, mais casse la lisibilité du pipeline |
| Quality Gate SonarCloud en échec (dépendances non verrouillées à une version exacte) | Projet 3, reconfirmé Projet 8 Jour 1 | Nécessiterait un fichier de lock complet, jugé hors périmètre pédagogique |
| Couverture de tests minimale (2 tests au total) | Projet 3, Projet 8 Jour 2 | L'objectif du parcours est la chaîne DevOps, pas la couverture applicative exhaustive |
| `CHANGELOG.md` incomplet (seule `v1.0.0` documentée pendant des mois) | Projet 8, Jour 1 | Oubli réel, corrigé pendant ce projet — pas une limite assumée, une vraie faute de suivi |
| `blue` et `green` partagent la même base PostgreSQL | ADR-002 (Projet 6) | Simplicité pédagogique — deviendrait un vrai risque si une migration de schéma incompatible était introduite |
| Aucune limite/requête de ressources (`requests`/`limits`) sur les Deployments Kubernetes | Projet 8, Jour 2 (diagnostics IDE) | Un pod pourrait en théorie consommer toutes les ressources du nœud sans être contenu — démontré indirectement au Projet 7 (test de charge CPU) |
| Aucune notification externe configurée sur les alertes (Slack/email) | Projet 7, Jour 4 | Optionnel selon le brief ; la preuve dans Prometheus/Alertmanager/Grafana a été jugée suffisante pour ce parcours |
| State Terraform local uniquement (pas de backend distant) | Projet 8, Jour 4 | Acceptable pour un lab à une seule personne |
| Blue/green double la consommation de ressources en permanence | ADR-002 (Projet 6) | Acceptable ici car l'application est très légère |

## Améliorations proposées (réalistes, priorisées)

1. **Requests/limits de ressources Kubernetes** — la plus urgente : sans elle, aucune des autres protections (HPA, quotas de namespace) n'a de sens.
2. **Meilleure gestion des secrets** — actuellement générés et stockés manuellement sur le VPS ; un vrai coffre-fort (Vault, Sealed Secrets, SOPS) éliminerait la dépendance à une procédure manuelle documentée mais non automatisée.
3. **Notifications Alertmanager** — brancher un canal réel (Slack/email) transformerait la supervision de "consultable" à "proactive".
4. **HTTPS et nom de domaine** — l'application et les interfaces d'observabilité sont actuellement en HTTP brut sur IP, acceptable en lab, pas en production.
5. **Sauvegardes PostgreSQL plus robustes** — actuellement pas de stratégie de sauvegarde/restauration automatisée démontrée pour la base applicative.
6. **Ingress propre** plutôt que des `NodePort` multiples (30030, 30090, 30093, 30080, 30843...) — plus lisible, permettrait aussi le point 4 (HTTPS) plus naturellement.
7. **Registre privé mieux sécurisé** — rotation des identifiants, scan de vulnérabilités des images publiées.
8. **Tests de bout en bout** — actuellement seulement des tests unitaires ; un test qui vérifie le parcours complet (créer une tâche, la lire, la supprimer) via l'API déployée renforcerait la confiance à chaque déploiement.

## Améliorations hors de portée réaliste pour ce parcours (mais nommées honnêtement)

- Autoscaling, environnement de staging séparé, modules Terraform réutilisables, tracing distribué, un véritable fournisseur cloud (AWS/GCP/Azure), stratégie de reprise après sinistre — toutes pertinentes pour une vraie production, mais demanderaient une infrastructure et un budget que ce parcours pédagogique n'a jamais eus pour objectif de couvrir. Les nommer explicitement ici plutôt que de les ignorer fait partie de la posture de consultant honnête attendue par ce projet.

## Ce que cette liste démontre

Savoir nommer précisément les limites d'un système — pas vaguement, avec l'endroit exact où chacune a été rencontrée — est ce qui distingue un consultant junior crédible d'une présentation qui prétend que tout est parfait.
