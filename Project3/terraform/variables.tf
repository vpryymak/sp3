variable "additional_tags" {
  type        = map(string)
  description = "Map of tags to apply to resources"
  default = {
    "student"  = "priima"
    "homework" = "Homework_terraform"
  }
}


variable "vpc_cidr_block" {
  type        = string
  default     = "10.0.0.0/16"
  description = "VPC CIDR block to user"
}

variable "public_cidr" {
  type        = string
  default     = "10.0.13.0/24"
  description = "Public subnet CIDR"
}

variable "private_cidr" {
  type        = string
  default     = "10.0.44.0/24"
  description = "Private subnet CIDR"
}
