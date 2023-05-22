output "cloud_provider_name" {
  value = harness_cloudprovider_kubernetes.this.name
}

output "cloud_provider_id" {
  value = harness_cloudprovider_kubernetes.this.id
}

output "token_secret_name" {
  value = harness_encrypted_text.token.name
}
