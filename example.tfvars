project_name      = "sandbox"
env               = "staging"
high_availability = false
aws_region        = "eu-west-1"
domains           = {
  "example.com" = ["*.example.com"],
  "example.edu" = ["api.example.edu", "*.api.example.edu", "www.example.edu"],
}
tags = {
  terraformSource = "https://github.com/ymakhloufi/terraform-aws-eks-cluster"
}
