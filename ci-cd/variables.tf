variable "web_instance_count" {
  type        = number
  description = "Number of web instances to deploy. This application requires at least two instances."
  default = 2
  validation {
    condition     = var.web_instance_count > 1
    error_message = "This application requires at least two web instances."
  }
}
