{ pkgs, perSystem, inputs }:
let
  devshell = pkgs.callPackage inputs.devshell { inherit inputs; };
  foundry = pkgs.callPackage "${inputs.foundry}/foundry-bin" {};
  unstable = perSystem.nixpkgs_unstable;
in
devshell.mkShell {
  packages = [
    pkgs.nixos-anywhere
    pkgs.opentofu
    pkgs.terragrunt
    pkgs.ssh-to-age
    pkgs.sops
    pkgs.gnumake
    pkgs.k3s
    pkgs.k9s
    pkgs.python3
    pkgs.nodejs_20
    pkgs.kubernetes-helm
    pkgs.kn
    pkgs.apacheHttpd
    pkgs.go_1_23
    pkgs.gcc
    pkgs.checkov
    foundry
  ];

  commands = [
    {
      name = "tg";
      category = "ops";
      help = "terragrunt alias";
      command = ''${unstable.terragrunt}/bin/terragrunt "$@"'';
    }
    {
      name = "tf";
      category = "ops";
      help = "opentofu alias";
      command = ''${unstable.opentofu}/bin/tofu "$@"'';
    }
  ];
}