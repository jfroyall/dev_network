variable "vm_condition_poweron" {
  description = "Set to true if the instances are defined"
  default = true
}

variable "instance_count" {
  type        = number
  description = "Number of instances to deploy. This application requires at least two instances."
  default     = 2
  validation {
    condition     = var.instance_count > 1
    error_message = "This application requires at least two web instances."
  }
}

variable "web_instance_count" {
  type        = number
  description = "Number of web instances to deploy. This application requires at least two instances."
  default     = 2
  validation {
    condition     = var.web_instance_count > 1
    error_message = "This application requires at least two web instances."
  }
}

#variable "db_disk_size" {
# type        = number
# description = "Disk size for the API database"
# default     = 100
#}
#
#variable "db_password" {
# type        = string
# description = "Database password"
# sensitive   = true
#}
#
