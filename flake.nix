{
  inputs = {
    nixpkgs = { url = "github:NixOS/nixpkgs/nixos-unstable"; };
    systems.url = "github:nix-systems/default";
  };

  outputs = { self, nixpkgs, systems, ... }@inputs:
    let
      eachSystem = f:
        nixpkgs.lib.genAttrs (import systems) (system:
          f (import nixpkgs {
            inherit system;
            config = { allowUnfree = true; };
            overlays = [ ];
          }));
    in {

      devShells = eachSystem (pkgs: {
        default = pkgs.mkShell {
          hardeningDisable = [ "all" ];
          buildInputs = [ ];

          packages = [
            pkgs.opentofu
            pkgs.terragrunt
            pkgs.grpcurl
          ];
        };
      });
    };
}