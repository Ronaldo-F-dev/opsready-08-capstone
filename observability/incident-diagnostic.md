# Méthode de diagnostic d'incident — synthèse

Résumé de la démarche appliquée au Jour 3. Rapport complet : [`docs/final-incident-report.md`](../docs/final-incident-report.md).

## La méthode, dans l'ordre, à répéter pour tout incident

1. **Identifier le symptôme** — qu'est-ce qui est visiblement anormal ? (`kubectl get pods`, un pod pas `Ready`, pas `Running`, qui redémarre...)
2. **Mesurer l'impact** — qui est réellement affecté ? Le Service actif est-il concerné, ou seulement une version standby ?
3. **Vérifier Grafana** — les métriques confirment-elles le symptôme (readiness, redémarrages, CPU/RAM) ?
4. **Vérifier Alertmanager / les règles Prometheus** — une alerte s'est-elle déclenchée ? Est-ce cohérent avec le symptôme ?
5. **Vérifier Loki** — que disent les logs de l'application concernée ? (souvent l'étape la plus révélatrice)
6. **Vérifier ArgoCD** — `Synced` (le problème vient de Git) ou `OutOfSync` (dérive manuelle) ? `Healthy` ou bloqué en `Progressing`/`Degraded` ?
7. **Vérifier Kubernetes avec `kubectl describe`/`kubectl logs`/`kubectl get events`** — confirmation technique précise de la cause.
8. **Identifier une cause probable** — à ce stade, la cause doit être évidente si les 7 étapes précédentes ont été suivies dans l'ordre.
9. **Appliquer un correctif ou proposer un rollback** — toujours via Git (commit + push), jamais par une modification directe du cluster.
10. **Vérifier le retour à la normale** — pods sains, ArgoCD `Synced`/`Healthy`, alerte résolue (en tenant compte du délai de "staleness" normal de Prometheus).

## Pourquoi cet ordre précis

Chaque étape élimine des causes possibles avant de passer à la suivante : Grafana élimine/confirme une tendance globale, Alertmanager confirme que la détection automatique fonctionne, Loki donne souvent la cause exacte en quelques secondes (comme au Jour 3 : des requêtes répétées vers un chemin inexistant), ArgoCD situe la panne entre "erreur dans Git" et "dérive manuelle", et `kubectl` fournit la confirmation technique finale. Sauter des étapes revient à deviner plutôt que diagnostiquer — exactement ce que le brief interdit ("vous ne devez pas lancer de commandes au hasard").

## Ce qui a été réellement démontré (Jour 3)

Incident réel (pas simulé sur papier) : `readinessProbe` cassée sur `green`, détectée en moins de 3 minutes via cette méthode complète, cause identifiée avec certitude par les logs Loki puis confirmée par `kubectl describe`, corrigée par un commit GitOps d'une ligne, retour à la normale vérifié.
