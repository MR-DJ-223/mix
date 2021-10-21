variable "required_tags" {
  type        = map(string)
  description = "Required tags to describe application"
  default = {
    das_application_name  = "" # DTC, NPOP, Lighthouse, etc
    das-env  = "" # dev, int, sqa, prf, ppd, prd, etc
    das-version = "" # version number for application
  }
}

variable "other_tags" {
  # eg. cust-type, cust_name, cust-env
  type        = map(string)
  description = "Other tags"
  default     = {}
}