# Checklist de diagnostic d'incident

Version condensée, prête à suivre en direct pendant la soutenance. Méthode complète expliquée : [`observability/incident-diagnostic.md`](../observability/incident-diagnostic.md). Exemple réel appliqué : [`final-incident-report.md`](final-incident-report.md).

- [ ] **Symptôme** — noter précisément ce qui est anormal, sans supposition (`kubectl get pods`, un dashboard, une alerte reçue)
- [ ] **Impact** — le Service actif est-il concerné ? Vérifier directement (`curl` sur l'URL publique), ne jamais présumer
- [ ] **Grafana** — les métriques confirment-elles et précisent-elles le symptôme ?
- [ ] **Alertmanager / règles Prometheus** — une alerte correspondante existe-t-elle, est-elle `pending`/`firing` ?
- [ ] **Loki** — que disent les logs de l'application concernée ? (souvent l'étape la plus rapide vers la cause)
- [ ] **ArgoCD** — `Synced` (vient de Git) ou `OutOfSync` (dérive manuelle) ? `Healthy` ou bloqué ?
- [ ] **`kubectl describe` / `kubectl logs` / `kubectl get events`** — confirmation technique précise
- [ ] **Cause probable** — énoncée clairement, appuyée par au moins deux des étapes précédentes
- [ ] **Correctif ou rollback** — toujours via un commit Git (voir [`rollback-checklist.md`](rollback-checklist.md))
- [ ] **Retour à la normale vérifié** — pods sains, ArgoCD `Synced`/`Healthy`, alerte résolue (en tenant compte du délai de "staleness" normal de Prometheus)
- [ ] **Documenté** — rapport d'incident rédigé pendant ou immédiatement après, pas de mémoire a posteriori

## Règle d'or

Ne jamais lancer de commande au hasard en espérant "voir ce qui se passe". Chaque étape doit être motivée par ce que l'étape précédente a montré — expliquer à voix haute le raisonnement (« je vois X, donc je vérifie Y ») est ce qui distingue un diagnostic méthodique d'une réaction de panique.
