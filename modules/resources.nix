{ config, pkgs, lib, ... }:
let
  ipType = lib.types.strMatching "([0-255]\.){4}";
in

{
  options.resources = with lib; {
    email = mkOption {
      type = types.strMatching ".+@.+\..+";
      example = "foobar@example.com";
      description = "Email address";
    };

    username = mkOption {
      type = types.str;
      example = "foobar";
      description = "Username";
    };

    fullName = mkOption {
      type = types.str;
      example = "John Doe";
      description = "Full name";
    };

    domainName = mkOption {
      type = types.str;
      example = "example.com";
      default = "local";
      description = "Domain name";
    };

    base16.theme = mkOption {
      type = types.str;
      example = "tomorrow-night";
      description = "Base16 theme name";
    };

    graphics.enable = mkEnableOption "graphical user interface";

    histsize = mkOption {
      type = types.ints.unsigned;
      default = 10000;
      description = "HISTSIZE value";
    };

    ssh.publicKeys = mkOption {
      type = with types; listOf str;
      example = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFSZ+ZWFCat0Fvog7XpS7mnNK9Mig+bi9LRqTHofBzIe" ];
      description = "Public SSH keys to allow access to";
    };

    gpg.publicKey.fingerprint = mkOption {
      type = types.strMatching "[[:alnum:]]{40}";
      description = "GPG key fingerprint";
    };

    duckduckgo.key = mkOption {
      type = types.str;
      description = "DuckDuckGo key";
    };

    jicofo.authPassword = mkOption {
      type = types.str;
      description = "XMPP password for Jicofo client connections";
    };

    jicofo.componentSecret = mkOption {
      type = types.str;
      description = "XMPP component password for Jicofo";
    };

    jvb.componentSecret = mkOption {
      type = types.str;
      description = "XMPP component password for Jitsi Videobridge";
    };

    soundcloud.token = mkOption {
      type = types.str;
      description = "SoundCloud API token";
    };

    spotify.username = mkOption {
      type = types.str;
      description = "Spotify username";
    };

    spotify.password = mkOption {
      type = types.str;
      description = "Spotify password";
    };

    spotify.clientID = mkOption {
      type = types.str;
      description = "Spotify client ID";
    };

    spotify.clientSecret = mkOption {
      type = types.str;
      description = "Spotify client secret";
    };

    wireguard.client.privateKey = mkOption {
      type = types.str;
      description = "Wireguard client private key";
    };

    wireguard.presharedKey = mkOption {
      type = types.str;
      description = "Wireguard preshared key";
    };

    programs = let
      progOption = {
        options = {
          executable = mkOption {
            type = types.submodule {
              options = {
                name = mkOption {
                  type = types.str;
                  description = "Name of the executable";
                };

                path = mkOption {
                  type = types.str;
                  description = "Absolute path to the executable";
                  readonly = true;
                };
              };
            };
            description = "Executable";
          };

          package = mkOption {
            type = types.package;
            description = "Package";
          };
        };
      };

      mkProgOption = args: mkOption args // {
        type = if args ? type then args.type else types.submodule progOption;
        apply = (opt:
        let
          _opt = if args ? apply then args.apply opt else opt;
        in rec {
          inherit (_opt) package;
          executable = _opt.executable // {
            path = "${package}/bin/${executable.name}";
          };
        });
      };
    in
    {
      browser = mkProgOption {
        example.package = pkgs.chromium;
        example.executable.name = "chromium";
        description = "Web browser";
      };

      editor = mkProgOption {
        example.package = pkgs.neovim;
        example.executable.name = "nvim";
        description = "Text editor";
      };

      mailer = mkProgOption {
        example.package = pkgs.thunderbird;
        example.executable.name = "thunderbird";
        description = "Email client";
      };

      pager = mkProgOption {
        example.package = pkgs.less;
        example.executable.name = "less";
        description = "Pager";
      };

      shell = mkProgOption {
        type = types.submodule {
          options = {
            executable = progOption.options.executable;
            package = mkOption {
              type = types.shellPackage;
              description = progOption.options.package.description;
            };
          };
        };
        example.package = pkgs.zsh;
        example.executable.name = "zsh";
        description = "Shell";
      };

      terminal = mkProgOption {
        example.package = pkgs.kitty;
        example.executable.name = "kitty";
        description = "Terminal emulator";
      };
    };
  };
}