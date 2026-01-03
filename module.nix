{
  config,
  lib,
  pkgs,
  options,
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

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      # 1. Home Manager Config
      (lib.mkIf (options ? home.packages) {
        home.packages = [ finalPackage ];
      })

      # 2. NixOS System Config
      (lib.mkIf (options ? environment.systemPackages) {
        environment.systemPackages = [ finalPackage ];
      })
    ]
  );
}
