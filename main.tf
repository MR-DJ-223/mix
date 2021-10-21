# https://docs.aws.amazon.com/general/latest/gr/aws_tagging.html

data "aws_region" "current" {}

locals {
  # The following regex is used to enforce only valid characters are used 
  # for tags. The regex is used to in the replace method to replace all 
  # but the characters listed in the regex. The '^' tells replace() to 
  # look for chars in the string which are not these and replace them with
  # spaces.
  regex = "/[^0-9a-zA-Z+\\-=._:/@]/"

  das_application_name  = lookup(var.required_tags, "das_application_name", null)
  das_env  = lookup(var.required_tags, "das_env", null)
  das_version = lookup(var.required_tags, "das_version", null)

  required_tags = {
    "das_application_name" : local.das_application_name != null ? replace(local.das_application_name, local.regex, " ") : ""
    "das_env" : local.das_env != null ? replace(local.das_env, local.regex, " ") : ""
    "das_version" : local.das_version != null ? replace(local.das_version, local.regex, " ") : ""
  }

  region_tag = { "region" = data.aws_region.current.name }

  # Final tag map
  tag_map = merge(local.required_tags, local.region_tag, var.other_tags)
}