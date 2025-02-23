# EigenDA

Make sure you have something to restake. More info can be found [here](https://docs.eigenlayer.xyz/eigenlayer/restaking-guides/restaking-user-guide/liquid-restaking/restake-lsts).

Follow the instructions to register an operator on EigenLayer found on this [register-operator](https://docs.eigenlayer.xyz/eigenlayer/operator-guides/operator-installation).

After you have registered an operator, you need to update the secrets and configurations to match your chosen values and then you should be able to start the operator.

## Health check

```
$ grpcurl -plaintext -d '{"service": "node.Retrieval"}' <REMOTE_IP>:32004 grpc.health.v1.Health/Check
{
  "status": "SERVING"
}
```

```
$ grpcurl -plaintext -d '{"service": "node.Dispersal"}' <REMOTE_IP>:32005 grpc.health.v1.Health/Check
{
  "status": "SERVING"
}
```

## Opt-In

When health checks are successful, you can opt-in to the EigenLayer network.

Uncomment `opt-in-job.tf` and modify it according to your needs. Then apply it with `terragrunt`.
