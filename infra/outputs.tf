output "client_public_ip" {
  value = "ssh adminuser@${azurerm_public_ip.client.ip_address}"
}

output "tfe_public_ip" {
  value = "ssh adminuser@${azurerm_public_ip.tfe_instance.ip_address}"
}

output "tfe_appplication" {
  value = "https://${var.dns_hostname}.${var.dns_zonename}"
}

output "ssh_tfe_server" {
  value = "ssh adminuser@${var.dns_hostname}.${var.dns_zonename}"
}

# output "client_certificate" {
#   value     = azurerm_kubernetes_cluster.example.kube_config.0.client_certificate
#   sensitive = true
# }

# output "kube_config" {
#   value = azurerm_kubernetes_cluster.example.kube_config_raw

#   sensitive = true
# }

locals {
  namespace = "terraform-enterprise"
  full_chain = "${acme_certificate.certificate.certificate_pem}${acme_certificate.certificate.issuer_pem}"
}

output "full_chain_encoded" {
  value = base64encode(local.full_chain)
}

output "private_key_encoded" {
  value = base64encode(nonsensitive(acme_certificate.certificate.private_key_pem))
}
