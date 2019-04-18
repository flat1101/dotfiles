{ config, pkgs, lib, ... }:
let
  mountOpts = [ "noatime" "nodiratime" "discard" ];
in
  {
    imports = [
      ./../../../resources/hosts/neon
      ./../../../vendor/nixos-hardware/common/pc/laptop/ssd
      ./../../../vendor/secrets/nixos/hosts/neon
      ./../../../vendor/secrets/resources/hosts/neon
      ./../../hardware/lenovo/thinkpad/x260
      ./../../profiles/laptop
      ./hardware-configuration.nix
    ];

    config = {
      boot.initrd.luks.devices = [
        {
          name="luksroot";
          device="/dev/sda2";
          preLVM=true;
          allowDiscards=true;
        }
      ];

      boot.kernelPackages = pkgs.linuxPackages_4_14;

      fileSystems."/".options = mountOpts;
      fileSystems."/home".options = mountOpts;

      networking.hostName = "neon";
      networking.firewall.allowedUDPPorts = [
        1700
      ];

      nix.nixPath = lib.mkBefore [
        "home-manager=${toString ./../../../vendor/home-manager}"
        "nixos-config=${toString ./.}"
        "nixpkgs-overlays=${toString ../../../nixpkgs/overlays.nix}"
        "nixpkgs-unstable=${toString ../../../vendor/nixpkgs/nixos-unstable}"
        "nixpkgs=${toString ../../../vendor/nixpkgs/nixos}"
      ];
    };
  }
