# Talous - Proxmox - POC

## Pre-req's
### QEMU guest agent support (iso)
- You will need a custom ISO. To get this, navigate to https://factory.talos.dev/
- Scroll down and select your Talos version
- Then tick the box for siderolabs/qemu-guest-agent and submit
- This will provide you with a link to the bare metal ISO
- The lines we’re interested in are as follows
- Place this ISO onto a store on Proxmoxm we will use `iso_storage` and `iso_file` in the terraform later.

## Terraform Variables

The following variables are used in the Terraform configuration (`infra/variables.tf`):

| Variable                | Type    | Description                                                                 |
|-------------------------|---------|-----------------------------------------------------------------------------|
| `pm_api_url`            | string  | The URL of the Proxmox API endpoint.                                        |
| `pm_api_token_id`       | string  | The Proxmox API token ID. Used for authentication. Sensitive.               |
| `pm_api_token_secret`   | string  | The Proxmox API token secret. Used for authentication. Sensitive.           |
| `pm_tls_insecure`       | bool    | Whether to skip TLS verification for the Proxmox API. Default is `false`.   |

> **Note:** Sensitive variables should be handled securely and not committed to version control.


## Talos commands

```
talosctl gen config talos-proxmox-cluster https://192.168.1.225:6443 --output-dir _out --install-image factory.talos.dev/installer/ce4c980550dd2ab1b17bbf2b08801c7eb59418eafe8f279833297925d67c7515:v1.10.6 --install-disk '/dev/vda' --force

talosctl apply-config --insecure --nodes 192.168.1.225 --file _out/controlplane.yaml

```

``` powershell
$env:TALOSCONFIG = "$PWD\_out\talosconfig"
talosctl config node 192.168.1.225
talosctl config endpoint 192.168.1.225
```
or
``` sh
export TALOSCONFIG=./_out/talosconfig
talosctl config node 192.168.1.225
talosctl config endpoint 192.168.1.225
```

```
talosctl config info
```

```
talosctl bootstrap
```
wait for 2-3 mins

```
talosctl kubeconfig .
kubectl --kubeconfig=./kubeconfig get nodes
```

- Shudown VM, remove ISO, start vm.


## TO DO
Automate using `https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/cluster_kubeconfig`