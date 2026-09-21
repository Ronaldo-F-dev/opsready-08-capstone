# Mini-lab Terraform — provider Docker

**Avertissement honnête** (demandé explicitement par le brief) : ce mini-lab couvre les bases de Terraform, pas une maîtrise avancée. L'objectif est de savoir expliquer ce qui suit en entretien, pas de prétendre être expert.

## Ce que fait ce lab

Crée un conteneur Nginx avec Terraform, plutôt qu'avec `docker run`. Deux ressources :
- `docker_image.nginx` — télécharge l'image `nginx:1.27-alpine`
- `docker_container.nginx` — lance un conteneur à partir de cette image, port exposé sur l'hôte

## Les concepts, expliqués simplement

### Infrastructure as Code (IaC)

Décrire l'infrastructure souhaitée dans des fichiers texte (ici `.tf`) plutôt que de la construire à la main, commande par commande. Deux avantages concrets démontrés dans ce lab : l'infrastructure est reproductible (`terraform apply` donne le même résultat à chaque fois) et versionnable (ces fichiers vivent dans Git, comme du code).

### Provider

Un provider est le "traducteur" entre Terraform et une plateforme cible — ici [`kreuzwerker/docker`](https://registry.terraform.io/providers/kreuzwerker/docker/latest), qui sait parler à l'API Docker locale. D'autres providers existent pour AWS, Kubernetes, GitHub, etc. — Terraform lui-même ne sait rien faire sans provider, il ne fait qu'orchestrer.

### Resource

Un bloc `resource` décrit un objet concret que le provider doit créer, modifier ou supprimer — ici une image Docker et un conteneur. Chaque resource a un type (`docker_image`, `docker_container`) et un nom local (`nginx`) utilisé pour la référencer ailleurs dans la config (ex : `docker_image.nginx.image_id`).

### State

Après chaque `apply`, Terraform écrit un fichier `terraform.tfstate` : sa mémoire de ce qui existe réellement (IDs Docker réels, attributs actuels). C'est ce fichier qui lui permet, au prochain `plan`, de savoir que "rien n'a changé" sans avoir à tout redécouvrir de zéro — comparé avec [`evidence/terraform-plan.txt`](../evidence/terraform-plan.txt), exécuté juste après l'`apply`, qui confirme `No changes`.

**Point clé de sécurité (exigé par le brief)** : le fichier state peut contenir des informations sensibles (mots de passe, clés, IDs internes) selon les ressources gérées. Il n'est **jamais committé** dans ce dépôt — `.gitignore` exclut `*.tfstate` et `*.tfstate.*`. Dans une vraie équipe, le state est stocké à distance (backend S3, Terraform Cloud...), chiffré et partagé entre les personnes qui appliquent des changements — hors périmètre de ce lab pédagogique (state local uniquement).

### Variable

`var.host_port` et `var.nginx_version` ([`variables.tf`](variables.tf)) permettent de changer le comportement du lab sans toucher à `main.tf` — ex : `terraform apply -var="host_port=9090"` pour utiliser un autre port.

### Output

`terraform output` ([`outputs.tf`](outputs.tf)) affiche des informations utiles après un `apply` — ici l'URL d'accès et le nom du conteneur — sans avoir à aller les chercher manuellement dans Docker.

### Le cycle init / plan / apply / destroy

| Commande | Ce qu'elle fait | Pourquoi elle est nécessaire |
|---|---|---|
| `terraform init` | Télécharge le provider déclaré, prépare le dossier de travail | Sans ça, Terraform ne sait pas parler à Docker |
| `terraform plan` | Compare la config désirée à l'état réel, affiche ce qui *va* changer, sans rien changer | Permet de vérifier avant d'agir — jamais de surprise |
| `terraform apply` | Applique réellement les changements du plan | L'étape qui crée/modifie pour de vrai |
| `terraform output` | Affiche les valeurs de sortie définies | Lecture rapide du résultat sans ressortir de Docker |
| `terraform destroy` | Supprime toutes les ressources gérées par ce state | Nettoyage complet, symétrique de `apply` |

### Terraform vs Ansible

Terraform est **déclaratif et orienté état** : on décrit le résultat voulu, Terraform calcule et retient ce qui existe. Ansible est **procédural et orienté tâches** : on décrit une séquence d'actions à exécuter, sans mémoire d'état persistante entre deux exécutions (il réinterroge le système à chaque fois). En résumé : Terraform excelle à *provisionner* de l'infrastructure (créer des ressources), Ansible excelle à *configurer* ce qui existe déjà (installer des paquets, modifier des fichiers de config) — les deux sont souvent utilisés ensemble dans une vraie chaîne.

### Terraform vs ArgoCD

Les deux sont déclaratifs, mais à des niveaux différents. Terraform provisionne l'infrastructure **sous** Kubernetes (le cluster lui-même, un VPS, un réseau, un registre...) ou des ressources Kubernetes ponctuelles. ArgoCD, lui, gère ce qui tourne **dans** un cluster Kubernetes déjà existant, en synchronisant en continu depuis Git (voir [Projet 6/7](../gitops-repo-summary/)). Dans ce projet : Terraform n'a jamais touché au cluster k3s existant — volontairement, pour ne pas dupliquer ce qu'ArgoCD fait déjà bien.

## Reproduire ce lab

```bash
cd terraform-basics
terraform init
terraform plan -out=tfplan
terraform apply -auto-approve tfplan
terraform output
curl http://localhost:8090   # Nginx repond
terraform destroy -auto-approve
```

## Preuves

- [`evidence/terraform-init.txt`](../evidence/terraform-init.txt)
- [`evidence/terraform-plan.txt`](../evidence/terraform-plan.txt) — exécuté après l'`apply`, confirme `No changes` (idempotence)
- [`evidence/terraform-apply.txt`](../evidence/terraform-apply.txt) — inclut la vérification HTTP 200 hors Terraform
- [`evidence/terraform-destroy.txt`](../evidence/terraform-destroy.txt)

## Limites assumées de ce lab

- State local uniquement (pas de backend distant) — acceptable pour un lab à une seule personne, pas pour une équipe
- `.terraform.lock.hcl` ignoré par Git ici (suivant la structure demandée par le brief) — **à noter** : la pratique généralement recommandée par la documentation Terraform officielle est au contraire de **committer** ce fichier (il fige les versions exactes de provider, comme un `package-lock.json`), pour garantir que tout le monde utilise la même version. Choix assumé de suivre la structure imposée par le brief plutôt que la pratique la plus répandue.
- Pas de gestion de plusieurs environnements (dev/staging/prod) — un seul lab, un seul état
