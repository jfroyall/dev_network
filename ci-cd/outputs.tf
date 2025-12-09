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
#output "web_public_ip" {
# description = "Public IP of the web instance"
# value       = aws_instance.web.public_ip
#}
