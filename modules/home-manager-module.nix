# Home Manager Module
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.dmscripts;
  finalPackage = pkgs.callPackage ../package.nix {
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
      default = [ ];
      description = "List of scripts to install. If empty, installs all.";
    };

    manPages = lib.mkEnableOption "manpages";
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ finalPackage ];
  };
}
