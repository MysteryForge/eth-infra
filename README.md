# Ethereum Infrastructure Setup Guide

## Introduction

This repository provides a complete infrastructure setup for running Ethereum nodes and related services in a Kubernetes environment on bare metal servers. It includes everything needed to deploy and manage a Ethereum infrastructure stack, from server provisioning to application deployment.

⚠️ **Important Note**: The current setup runs a single Kubernetes master node, which is not recommended for production environments. Future updates will include a proper master + worker nodes configuration for high availability.

Key features:

- Bare metal server provisioning using NixOS
- Kubernetes cluster setup and management
- Multiple Ethereum client combinations (Geth+Lighthouse, Geth+Prysm, Erigon+Caplin)
- Staking infrastructure setup
- Monitoring and alerting
- Infrastructure as Code using Terraform and Terragrunt
- Secret management with SOPS
- Automated SSL certificate management

While originally designed for OVH bare metal servers, the Kubernetes configurations can be adapted for any infrastructure provider or existing Kubernetes cluster.

**TODO**:

- Implement proper Kubernetes cluster with master + worker nodes configuration

## Prerequisites

- OVH account with API access
- Domain registered in Cloudflare
- SSH key pair
- Basic knowledge of Kubernetes, Terraform, and NixOS
- direnv installed

Update all files that contain `zeth` with `[your_user]`, `my-domain.com` with `[your_domain]`, `ORG` with `[your_github_org]` and rename `ovh1` to `[your_host]` across the repository.

## 1. Initial Setup(OVH)

### 1.1 Generate OVH API Keys

Create `.envrc.local` from `.envrc.example` and fill in the required values.

### 1.2 Set Up SSH and SOPS

```bash
# Generate AGE key
mkdir -p ~/.config/sops/age
ssh-to-age -private-key -i ~/.ssh/[your_private_key] >> ~/.config/sops/age/keys.txt

# Generate SSH host key
ssh-keygen -t ed25519 -N "" -f hosts/[your_host]/ssh_host_ed25519_key

# Configure SOPS
cat <<SOPS > .sops.yaml
creation_rules:
  - path_regex: ^hosts/[your_host]/secrets.yaml$
    key_groups:
      - age:
        - $(ssh-to-age -i hosts/[your_host]/ssh_host_ed25519_key.pub)
        - $(ssh-to-age -i users/[your_user]/authorized_keys)
SOPS

# Generate and encrypt host secrets
cat <<SECRETS > hosts/[your_host]/secrets.yaml
ssh_host_ed25519_key: |
$(sed "s/^/  /" < hosts/[your_host]/ssh_host_ed25519_key)
SECRETS

sops --encrypt --in-place hosts/[your_host]/secrets.yaml
rm hosts/[your_host]/ssh_host_ed25519_key
```

## 2. NixOS Deployment

### 2.1 Generate Root Password Hash

```bash
# Method 1: Using mkpasswd (recommended)
mkpasswd -m sha-512

# Method 2: Using openssl
openssl passwd -6
```

Copy the generated hash and paste it into `modules/nixos/server.nix`.

### 2.2 Update zeth, my-domain.com and ORG

Update all files that contain `zeth` with [your_user], `my-domain.com` with [your_domain] and `ORG` with [your_github_org] across the repository.

### 2.3 Update `hosts/[your_host]/disko.nix`

Adjust the disk configuration according to your server's hardware.

### 2.4 Generate k3s Token

```bash
k3s token generate > hosts/[your_host]/k3s-token
```

### 2.5 Deploy NixOS

```bash
# Prepare SSH host key
temp=$(mktemp -d)
install -d -m755 "$temp/etc/ssh"
sops --decrypt --extract '["ssh_host_ed25519_key"]' hosts/[your_host]/secrets.yaml > "$temp/etc/ssh/ssh_host_ed25519_key"
chmod 600 "$temp/etc/ssh/ssh_host_ed25519_key"

# Deploy
nixos-anywhere --extra-files "$temp" --flake .#[your_host] [user]@[domain]
```

### 2.6 Rebuild NixOS (when needed)

```bash
nixos-rebuild --flake .#[your_host] --target-host root@[domain] switch
```

### 2.7 Test

```bash
ssh root@[domain]
kubectl get nodes
```

## 3. Kubernetes Setup

### 3.1 Bootstrap Kubernetes

```bash
# Create and encrypt k8s bootstrap secrets
cat > hosts/[your_host]/tf/k8s-bootstrap/secrets.yaml << EOF
cloudflare_api_token: [your_token]
acme_email: [your_email]
cloudflare_email: [your_email]
ghcr_token: [your_token]
github_client_id: [your_id]
github_client_secret: [your_secret]
oidc_grafana_secret: [your_secret]
doppler_token: [your_token]
discord_webhook_url: [your_webhook]
EOF

sops --encrypt --in-place hosts/[your_host]/tf/k8s-bootstrap/secrets.yaml

# Navigate to the k8s bootstrap directory
cd hosts/[your_host]/tf

# Apply CRDs
cd k8s-crds
tg init
tg apply

# Bootstrap cluster
cd ../k8s-bootstrap
tg init
tg apply
```

### 3.2 Connect to k8s

1. Copy the kubeconfig from your server:

```bash
ssh root@[domain] "cat /etc/rancher/k3s/k3s.yaml" > hosts/[your_host]/kubeconfig
```

2. Update the server address in the kubeconfig to use your domain name instead of the default localhost.

Note: The TLS certificates are stored on the server at `/var/lib/rancher/k3s/server/tls`. OIDC authentication will be implemented in a future update to replace the default kubeconfig authentication.

### 3.3 Remove Master Node Taint (if needed)

If you need to schedule workloads on the master node (single-node setup), remove the master taint:

```bash
kubectl taint nodes --all node-role.kubernetes.io/master:NoSchedule-
```

## Holesky(deprecated)

- EigenDA (https://holesky.eigenlayer.xyz/operator/0x4b729ee53f0c4655a90644642374ce93f0b6590d)
- ETHStake (https://holesky.beaconcha.in/validator/92ea56b0ea17c78308f20c63ce20a890e1e5d7c55ede30579aa5b4bca856259f6a6ff5a31e8199606f1b31ce4d7855db)

## Important Notes

- SECURITY: Never commit unencrypted secrets

## License

All other files within this repository are licensed under the MIT License unless stated otherwise.

## Support

For professional support and consulting, contact [CuteTarantula](https://cutetarantula.com).
