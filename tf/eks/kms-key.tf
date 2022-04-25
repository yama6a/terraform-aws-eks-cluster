resource "aws_kms_key" "eks_secrets_key" {
  key_usage                = "ENCRYPT_DECRYPT"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  description              = "Key for EKS Cluster Secrets Encryption"
  enable_key_rotation      = true
}
