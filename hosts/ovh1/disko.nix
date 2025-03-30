# example configuration for disko, please modify accordingly
let
  lvmDisk = idx: {
    type = "disk";
    device = "/dev/nvme${idx}n1";
    content = {
      type = "lvm_pv";
      vg = "pool";
    };
  };
in
{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            boot = {
              size = "1M";
              type = "EF02"; # for grub MBR
            };
            ESP = {
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "50G";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
            pv = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };
      lvma = lvmDisk "1";
    };

    # Create an empty pool for openebs-lvm
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = { };
      };
    };
  };
}