variable "bucket_name" {
  description = "Name of the storage bucket"
  type        = string
}

variable "location" {
  description = "Bucket location"
  type        = string
  default     = "US"
}

variable "uniform_bucket_level_access" {
  description = "Enable uniform bucket-level access"
  type        = bool
  default     = false  # VULNERABLE: Defaults to false
}

variable "enable_versioning" {
  description = "Enable object versioning"
  type        = bool
  default     = false  # VULNERABLE: Defaults to false
}

variable "enable_public_read" {
  description = "Enable public read access"
  type        = bool
  default     = true  # VULNERABLE: Defaults to true
}

variable "enable_public_write" {
  description = "Enable public write access"
  type        = bool
  default     = true  # VULNERABLE: Defaults to true
}

variable "admin_members" {
  description = "Members with admin access to bucket"
  type        = set(string)
  default = [
    "allAuthenticatedUsers",  # VULNERABLE: Default includes all authenticated users
    "allUsers"                # VULNERABLE: Default includes all users
  ]
}