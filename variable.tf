# variables.tf
variable "db_password" {
  description = "The password for the database"
  type        = string
  sensitive   = true  # This hides it from logs!
}