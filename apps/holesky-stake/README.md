# ETH Staking

With this setup we decided not to use external secrets, but instead use Kubernetes secrets created from data of local files.

## Setup

Before setting up Dirk and Vouch, you need to decide on the number of Dirk and Vouch instances you want to run. In the example below, there is one Dirk and one Vouch instance, but it is recommended to run a distributed setup with at least 3 Dirk and 2 Vouch instances. This also means that you would be using a `distributed` wallet. The steps below will guide you on what needs to change.

### Fill Out Variables

Set the following environment variables:

```sh
export TF_VAR_vouch_fee_recipient=<your_fee_recipient>
export TF_VAR_vouch_fallback_fee_recipient=<your_fallback_fee_recipient>
```

### Create Certificates

Run the following script to create the necessary certificates:

```sh
./create-config.sh
```

### Create dirk module

```hcl
module "dirk0" {
  source             = "${var.modules_pth}/k8s-dirk"
  uid                = 1000
  name               = "dirk0"
  dirk_crt           = "${path.module}/config/certs/dirk0.crt"
  dirk_key           = "${path.module}/config/certs/dirk0.key"
  namespace          = kubernetes_namespace.holesky_stake.metadata[0].name
  dirk_authority     = kubernetes_secret.dirk_authority.metadata[0].name
  wallet_passphrase  = kubernetes_secret.wallet_passphrase.metadata[0].name
  account_passphrase = kubernetes_secret.account_passphrase.metadata[0].name
  wallet_name        = "wallet0"
  wallet_type        = "nd" // or "distributed"
  peers = yamlencode({
    "1000" : "dirk0:13141"
    // Add more peers here if you have a distributed setup
  })
  permissions = yamlencode({
    "vouch0" : {
      "wallet0" : "All"
    }
    // Add more permissions here if you are running multiple vouch instances or have multiple wallets
  })
}
```

Repeat the module configuration for additional dirk instances, adjusting the `uid`, `name`, and other parameters as needed.

### Create vouch module

```hcl
module "vouch0" {
  source             = "${var.modules_pth}/k8s-vouch"
  name           = "vouch0"
  dirk_authority = kubernetes_secret.dirk_authority.metadata.0.name
  vouch_key      = "${path.module}/config/certs/vouch0.key"
  vouch_crt      = "${path.module}/config/certs/vouch0.crt"
  namespace      = kubernetes_namespace.holesky_stake.metadata.0.name
  beacon_node_addresses = yamlencode([
    "http://geth-lighthouse.holesky-geth-lighthouse.svc:3500",
    // ... repeat for other beacon nodes
  ])
  graffiti = "MysteryForge"
  blockrelay_config = jsonencode({
    fee_recipient : var.vouch_fee_recipient,
    gas_limit : 30000000,
    relays : {
      "https://boost-relay-holesky.flashbots.net/" : {
        public_key : "0xafa4c6985aa049fb79dd37010438cfebeb0f2bd42b115b89dd678dab0670c1de38da0c4e9138c9290a398ecd9a0b3110"
      }
    }
  })
  fallback_fee_recipient = var.vouch_fallback_fee_recipient
  dirk_endpoints = yamlencode([
    "dirk0:13141"
    // ... repeat for dirk1, dirk2, etc.
  ])
  wallets = yamlencode([
    "wallet0"
  ])
}
```

Repeat the module configuration for additional vouch instances, adjusting the `uid`, `name`, and other parameters as needed.

### Notes

- Ensure that the certificates and keys are correctly generated and placed in the specified paths.
- Adjust the `namespace`, `dirk_authority`, `wallet_passphrase`, and `account_passphrase` values to match your Kubernetes secret configurations.
- For a distributed setup, ensure that the `peers` and `permissions` configurations are correctly set to include all Dirk and Vouch instances.

By following these steps, you can set up Dirk and Vouch instances for ETH staking in a Kubernetes environment.

### Deploy

```sh
alias tg='terragrunt'
tg init
tg apply
```

### Create accounts in wallets

You could use `ethdo` in k8s to create accounts in the wallets, but make sure that you are not exposing sensitive information when executing commands or doing it locally. At the moment we only have instructions for k8s.

#### k8s ethdo

Uncomment `ethdo.tf` and `tg apply` it. Then ssh into the `ethdo` pod and run the following commands:

```
# nd
./ethdo account create --remote=dirk0:13141 --server-ca-cert /config/certs/dirk_authority.crt --client-cert /config/certs/vouch0.crt --client-key /config/certs/vouch0.key --account=wallet0/account0

# distributed
./ethdo account create --remote=dirk0:13141 --server-ca-cert /config/certs/dirk_authority.crt --client-cert /config/certs/vouch0.crt --client-key /config/certs/vouch0.key --account=wallet0/account0 --signing-threshold=2 --participants=3
```

Verify account:

```
./ethdo account info --remote=dirk0:13141 --server-ca-cert /config/certs/dirk_authority.crt --client-cert /config/certs/vouch0.crt --client-key /config/certs/vouch0.key --account=wallet0/account0 --passphrase=<> --verbose
```

### Create deposit data (dirk0, vouch0, account0)

```
# fork version: 0x00000000 mainnet, 0x01017000 Holesky
./ethdo validator depositdata --depositvalue 32Ether --remote=dirk0:13141 --server-ca-cert /config/certs/dirk_authority.crt --client-cert /config/certs/vouch0.crt --client-key /config/certs/vouch0.key --validatoraccount wallet0/account0 --launchpad --forkversion <fork_version> --withdrawaladdress <withdrawal_addr>
```

Copy the output into a file because we will use this when creating a validator.

### Stake a validator

https://holesky.launchpad.ethstaker.cc/

### Make a copy of all the `config` folder and store it somewhere safe. This is your backup.
