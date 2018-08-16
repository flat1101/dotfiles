{ config, pkgs, ... }:

{
  imports = [
    ./../..
    ./../../boards.nix
    ./../../graphical.nix
    ./../../mopidy.nix
    ./../../virtualbox.nix
  ];

  environment.systemPackages = with pkgs; [
    httpie
  ];

  home-manager.users.${config.meta.username} = import ../../../home/profiles/laptop;

  meta.graphics.enable = true;

  programs.adb.enable = true;

  services.printing.enable = true;

  sound.enable = true;
  sound.mediaKeys.enable = true;

  systemd.services.audio-off.description = "Mute audio before suspend";
  systemd.services.audio-off.enable = true;
  systemd.services.audio-off.serviceConfig.ExecStart = "${pkgs.pamixer}/bin/pamixer --mute";
  systemd.services.audio-off.serviceConfig.RemainAfterExit = true;
  systemd.services.audio-off.serviceConfig.Type = "oneshot";
  systemd.services.audio-off.serviceConfig.User = "${config.meta.username}";
  systemd.services.audio-off.wantedBy = [ "sleep.target" ];
}