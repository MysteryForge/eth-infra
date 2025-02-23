# Intro

This repository serves as code snippets for those interested in understanding and experimenting with infrastructure components related to the Ethereum ecosystem running in a kubernetes cluster.

At the moment we are using `terraform` and `terragrunt` to manage our kubernetes infrastructure. In case you are using a `CI/CD` I would recommend export the configurations into YAML and just use these files to deploy the infrastructure.

Our recommendation is to copy the code of the components you are interested in and adapt them to your needs.

We will be adding through time more components and configurations to this repository as we experiment with them in our own infrastructure to build a full Ethereum stack running in a kubernetes cluster.

## ETH Solutions

- EigenDA
- ETH Stake
- Geth+Lighthouse
- Optimism L2

# Getting Started

## Prerequisites

Tools required:

- terraform
- terragrunt
- kubectl

A working kubernetes cluster is required with the following infra:

- openebs
- ingress-nginx
- external-secrets
- external-dns
- cert-manager
- loki
- grafana
- prometheus or victoria-metrics

## Holesky

- EigenDA (https://holesky.eigenlayer.xyz/operator/0x4b729ee53f0c4655a90644642374ce93f0b6590d)
- ETHStake (https://holesky.beaconcha.in/validator/92ea56b0ea17c78308f20c63ce20a890e1e5d7c55ede30579aa5b4bca856259f6a6ff5a31e8199606f1b31ce4d7855db)

## License

All other files within this repository are licensed under the MIT License unless stated otherwise.

## Support

This project is supported by [CuteTarantula](https://cutetarantula.com).

We are a UK-based consultancy specializing in Ethereum and blockchain solutions. Whether you have an exciting project idea or need expert guidance on any of our supported tools, we’re here to help. Don’t hesitate to reach out, we’d love to collaborate with you!
