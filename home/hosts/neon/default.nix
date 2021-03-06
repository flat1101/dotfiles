{ pkgs, ... }:
{
  imports = [
    ../../lan.nix
  ];

  home.packages = with pkgs; [
    engify
    mkvtoolnix
  ];

  home.sessionVariables.PASSWORD_STORE_DIR = toString ./../../../vendor/pass;

  programs.ssh.matchBlocks."cobalt".hostname = "cobalt.lan";
  programs.ssh.matchBlocks."oxygen".hostname = "oxygen.external";
  programs.ssh.matchBlocks."oxygen-luks".hostname = "oxygen.external";
  programs.ssh.matchBlocks."zinc".hostname = "zinc.lan";
}
