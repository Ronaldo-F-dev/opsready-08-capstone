output "nginx_url" {
  description = "URL locale pour acceder au conteneur Nginx cree par ce lab."
  value       = "http://localhost:${var.host_port}"
}

output "container_name" {
  description = "Nom du conteneur Docker cree."
  value       = docker_container.nginx.name
}
