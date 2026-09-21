# Checklist de déploiement

À suivre pour tout changement applicatif, du commit jusqu'à la vérification en production. Basée sur le flux réellement démontré au Jour 2 ([`day2-full-demo.md`](day2-full-demo.md)).

- [ ] Travailler sur une branche dédiée (`feat/...`, `fix/...`), jamais directement sur `main`
- [ ] Le changement est petit et testable (un seul changement logique)
- [ ] Un test a été ajouté ou mis à jour pour couvrir le changement
- [ ] `ruff check` et les tests passent en local avant de pousser
- [ ] Commit rédigé selon la convention du projet ([`docs/prj3/commit-convention.md`](https://github.com/Ronaldo-F-dev/devops-prj3/blob/main/docs/prj3/commit-convention.md))
- [ ] Pull Request ouverte, pipeline CI vert (`lint`, `test`, `Gitleaks`, `SonarCloud`, `Build and push Docker image`)
- [ ] Fusion sur `main` seulement après pipeline vert
- [ ] Tag de version créé (`vX.Y.Z`, jamais `latest`) si une nouvelle version doit être publiée
- [ ] Image vérifiée disponible dans le registre (`docker manifest inspect`)
- [ ] Tag d'image mis à jour dans le dépôt GitOps — **sur `green` (standby) d'abord**, jamais directement sur `blue` (actif), sauf décision explicite de bascule
- [ ] ArgoCD détecte le changement, `Synced` puis `Healthy`
- [ ] Rollout vérifié : nouveau pod `Running`, `Ready`, `0` redémarrage inattendu
- [ ] `/health` et `/version` vérifiés directement sur le nouveau pod
- [ ] Visible dans Grafana (métriques) et Loki (logs) dans les secondes qui suivent
- [ ] Si tout est validé sur `green` : bascule du sélecteur du Service pour rendre la nouvelle version active, puis re-vérification via le Service public

## Pourquoi cet ordre

Chaque étape est une porte qui empêche un problème de se propager plus loin : tester avant de commit, committer avant de pousser, CI verte avant de fusionner, image vérifiée avant de la référencer en GitOps, `green` avant `blue` pour ne jamais risquer le trafic réel. Sauter une étape ne fait pas gagner du temps — ça déplace juste la découverte du problème plus tard, à un moment où il coûte plus cher à corriger.
