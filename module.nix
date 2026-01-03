{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.dmscripts;
  # callPackage automatically injects the dependencies from pkgs
  # and passes our config options as arguments.
  finalPackage = pkgs.callPackage ./package.nix {
    inherit (cfg) scripts displayServer manPages;
  };
in
{
  options.programs.dmscripts = {
    enable = lib.mkEnableOption "dmscripts";
    displayServer = lib.mkOption {
      type = lib.types.enum [
        "x11"
        "wayland"
        "both"
      ];
      default = "both";
      description = "Which display server dependencies to install.";
    };

    scripts = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        # Default handled in package.nix (installs all if empty)
      ];
      description = "List of scripts to install. If empty, installs all.";
    };

    manPages = lib.mkEnableOption "manpages";
  };

  config = lib.mkMerge [
    # For NixOS systems - only set if environment exists
    (lib.mkIf (cfg.enable && (config ? environment)) {
      environment.systemPackages = [ finalPackage ];
    })

    # For Home Manager - only set if home exists
    (lib.mkIf (cfg.enable && (config ? home)) {
      home.packages = [ finalPackage ];
    })
  ];
}
