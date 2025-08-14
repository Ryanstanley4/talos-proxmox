# Talous - Proxmox - POC

## Terraform Variables

The following variables are used in the Terraform configuration (`infra/variables.tf`):

| Variable                | Type    | Description                                                                 |
|-------------------------|---------|-----------------------------------------------------------------------------|
| `pm_api_url`            | string  | The URL of the Proxmox API endpoint.                                        |
| `pm_api_token_id`       | string  | The Proxmox API token ID. Used for authentication. Sensitive.               |
| `pm_api_token_secret`   | string  | The Proxmox API token secret. Used for authentication. Sensitive.           |
| `pm_tls_insecure`       | bool    | Whether to skip TLS verification for the Proxmox API. Default is `false`.   |

> **Note:** Sensitive variables should be handled securely and not committed to version control.