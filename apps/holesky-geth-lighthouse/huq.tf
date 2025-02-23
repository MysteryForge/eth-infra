module "node_huq" {
  source                 = "../../../../../modules/tf/k8s-geth-lighthouse"
  name                   = "huq"
  host                   = "holesky-node.${var.domain}"
  eth_network            = "holesky"
  basic_auth_secret_name = "ingress-basic-auth"
  namespace              = kubernetes_namespace.holesky_geth_lighthouse.metadata.0.name
  geth_pvc_size          = "150Gi"
  lighthouse_pvc_size    = "50Gi"
  geth_image             = "ethereum/client-go:v1.14.12"
  lighthouse_image       = "sigp/lighthouse:v6.0.1"
  geth_args = [
    "--holesky",
    "--datadir=/data/geth",
    "--port=14580",
    "--discovery.port=14580",
    "--http",
    "--http.addr=0.0.0.0",
    "--http.port=8545",
    "--http.rpcprefix=/",
    "--http.vhosts=*",
    "--http.api=eth,net,engine,web3,debug,admin,les,txpool",
    "--ws",
    "--ws.addr=0.0.0.0",
    "--ws.port=8546",
    "--ws.origins=*",
    "--ws.rpcprefix=/",
    "--ws.api=eth,net,engine,web3,debug,txpool",
    "--metrics",
    "--metrics.addr=0.0.0.0",
    "--metrics.port=6060",
    "--authrpc.jwtsecret=/jwtsecret",
    "--authrpc.addr=0.0.0.0",
    "--authrpc.port=8551",
    "--authrpc.vhosts=*"
  ]
  lighthouse_args = [
    "lighthouse",
    "beacon_node",
    "--network=holesky",
    "--http",
    "--http-address=0.0.0.0",
    "--http-port=3500",
    "--datadir=/data/lighthouse",
    "--metrics",
    "--metrics-address=0.0.0.0",
    "--metrics-port=6061",
    "--metrics-allow-origin=*",
    "--execution-jwt=/jwtsecret",
    "--execution-endpoint=http://localhost:8551",
    "--checkpoint-sync-url=https://holesky.beaconstate.info",
    "--prune-blobs=false",
    "--blobs-dir=/data/lighthouse-blobs",
    "--suggested-fee-recipient=0x00...00", // TODO: Update with actual address
  ]
}
