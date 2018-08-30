# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sdhci_pci" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call wireguard ];

  fileSystems."/" =
    { device = "/dev/mapper/partitions-butter";
      fsType = "btrfs";
      options = [ "subvol=@" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/820F-07DA";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/mapper/partitions-butter";
      fsType = "btrfs";
      options = [ "subvol=@home" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/35a70a8e-b311-4ea0-a87b-c1cf71e3b945"; }
    ];

  nix.maxJobs = lib.mkDefault 8;
}