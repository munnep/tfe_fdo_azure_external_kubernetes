# authentication uri
output "tfe_application_url" {
  value = "https://${var.dns_hostname}.${var.dns_zonename}"
}

output "execute_script_to_create_user_admin" {
  value = "./configure_tfe.sh ${var.dns_hostname}.${var.dns_zonename} patrick.munne@hashicorp.com Password#1"
}
