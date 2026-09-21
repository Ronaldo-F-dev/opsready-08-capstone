variable "nginx_version" {
  description = "Tag de l'image Docker Nginx a utiliser."
  type        = string
  default     = "1.27-alpine"
}

variable "host_port" {
  description = "Port de la machine hote sur lequel Nginx sera accessible."
  type        = number
  default     = 8090
}
