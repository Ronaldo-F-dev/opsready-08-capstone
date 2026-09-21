terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

# L'image Docker Nginx, tiree du registre officiel. Terraform la telecharge
# si elle n'est pas deja presente localement (comportement equivalent a
# "docker pull", mais declaratif : Terraform sait deja que cette ressource
# existe s'il la retrouve lors d'un futur "plan").
resource "docker_image" "nginx" {
  name = "nginx:${var.nginx_version}"
}

# Le conteneur lui-meme, construit a partir de l'image ci-dessus.
resource "docker_container" "nginx" {
  name  = "terraform-basics-nginx"
  image = docker_image.nginx.image_id

  ports {
    internal = 80
    external = var.host_port
  }
}
