resource "tls_private_key" "aks-admin-ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
