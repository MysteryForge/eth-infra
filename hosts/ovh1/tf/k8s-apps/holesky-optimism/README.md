# Optimism L2

Follow the instructions to deploy an Optimism L2 found on this [create-l2-rollup](https://docs.optimism.io/builders/chain-operators/tutorials/create-l2-rollup).

Our deployed version is based on the following releases:

- https://github.com/ethereum-optimism/optimism/releases/tag/op-contracts%2Fv1.6.0
- https://github.com/ethereum-optimism/optimism/releases/tag/v1.9.2

We used the contracts from `op-contracts/v1.6.0` because the contracts in the `v1.9.2` release were not working properly.

Our recommendation is that you try the latest stable version of `op-stack` and see if it works for you. Good luck!

When starting the sequencer, proposer, proxyd and batcher make sure you went through the secrets and configurations to update them to your chosen values.
