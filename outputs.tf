output "k8s-ssh-key-public-openssh" {
  value = tls_private_key.k8s-ssh-key.public_key_openssh
}
