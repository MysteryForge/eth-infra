{
  inputs,
  flake,
  config,
  ...
}:
{
  imports = [
    # Used for disk partitioning.
    inputs.disko.nixosModules.default
    # Used to manage shared secrets.
    inputs.sops-nix.nixosModules.default
    # Provides sane and hardened defaults for our server. Making sure SSH is up and running.
    inputs.srvos.nixosModules.server
  ];

  networking.nameservers = [ "1.1.1.1" ];

  # Allow you to SSH to the servers as root
  users.users.root.openssh.authorizedKeys.keyFiles = [
    "${flake}/users/zeth/authorized_keys"
  ];

  users.users."root".hashedPassword = ""; # provide your own password
  users.mutableUsers = false;

  # Provisions hosts with pre-generated host keys
  sops.secrets.ssh_host_ed25519_key = { };
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  services.openssh.hostKeys = [
    {
      path = config.sops.secrets.ssh_host_ed25519_key.path;
      type = "ed25519";
    }
  ];
}