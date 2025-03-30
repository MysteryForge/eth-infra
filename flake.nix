{
  description = "platform";

  inputs = {
    blueprint.url = "github:zimbatm/blueprint";

    disko.inputs.nixpkgs.follows = "nixpkgs";
    disko.url = "github:nix-community/disko";

    devshell.inputs.nixpkgs.follows = "nixpkgs";
    devshell.url = "github:numtide/devshell";

    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";

    treefmt-nix.url = "github:numtide/treefmt-nix";
    treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    srvos.url = "github:numtide/srvos";
    nixpkgs.follows = "srvos/nixpkgs";

    nixpkgs_unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    foundry.url = "github:shazow/foundry.nix/monthly"; # Use monthly branch for permanent releases
  };

  outputs = inputs: inputs.blueprint { inherit inputs; };
}