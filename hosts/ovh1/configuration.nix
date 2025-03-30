{ inputs, pkgs, flake, modulesPath, lib, ... }:
{
  imports = [
    ./disko.nix
    flake.nixosModules.server
    (modulesPath + "/profiles/all-hardware.nix")
    (modulesPath + "/profiles/base.nix")
  ];

  # The machine architecture.
  nixpkgs.hostPlatform = "x86_64-linux";

  # The machine hostname.
  networking.hostName = "ns3187207";
  networking.useDHCP = true;
  networking.enableIPv6 = true;
  networking.useNetworkd = true;
  networking.dhcpcd.enable = false;
  networking.firewall.enable = true;
  # ens+ Interfaces: If ens interfaces are used for internal or trusted network connections, marking them as trusted can allow open access to services without applying restrictive firewall rules.
  # cni+ Interfaces: For Kubernetes or container networking, marking cni interfaces as trusted can facilitate pod-to-pod and pod-to-service communication, which might be restricted otherwise.
  # k3s cluster communications between containers/pods and reduce firewall configuration complexity
  networking.firewall.trustedInterfaces = [
    "ens+"
    "cni+"
  ];
  networking.firewall.allowedTCPPorts = [
    2379
    2380
    6443
    6444
    10250
  ];
  networking.firewall.allowedUDPPorts = [ 8472 ];

  # garbage collection
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 7d";
  };

  # The boot loader configuration.
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    efiInstallAsRemovable = true;
    devices = [ "nodev" ];
  };
  nix.settings.auto-optimise-store = true;

  # k8s
  services.k3s = {
    enable = true;
    clusterInit = true;
    role = "server";
    tokenFile = ./k3s-token;
    extraFlags = [
      "--debug"
      "--disable traefik"
      "--disable local-storage"
      "--cluster-cidr 10.42.0.0/16"
      "--service-cidr 10.43.0.0/16"
      "--kubelet-arg=feature-gates=InPlacePodVerticalScaling=true"
      "--write-kubeconfig-mode 644"
      "--kube-apiserver-arg anonymous-auth=false"
      # change this to your server's domain
      "--tls-san ovh1.my-domain.com"
    ];
  };
  systemd.services.k3s.serviceConfig.RuntimeMaxSec = "89d";
  systemd.services.k3s.after = [ "systemd-netword.service" ];

  # The system packages to install.
  environment.systemPackages = with pkgs; [
    lsof
    dnsutils
    iptables
    sysz
    jq
    docker
  ];

  boot.kernel.sysctl = {
    "fs.inotify.max_queued_events" = lib.mkDefault 1048576;
    "fs.inotify.max_user_instances" = lib.mkDefault 2147483647;
    "fs.inotify.max_user_watches" = lib.mkDefault 1048576;
  };

  # Load secrets from this file.
  sops.defaultSopsFile = ./secrets.yaml;

  # Used by NixOS to handle state changes.
  system.stateVersion = "24.11";
}