{
  description = "Soliprem's fork of dmscripts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        runtimeDeps = with pkgs; [
          coreutils
          gnused
          gnugrep
          gawk
          findutils
          bash
          dmenu
          rofi
          fzf
          libnotify
          xclip
          wl-clipboard
          xdotool
          xorg.xrandr
          light
          upower
          procps # dm-kill

          # Network
          networkmanager # dm-wifi
          curl
          bind # dm-ip
          iproute2 # dm-ip

          # Multimedia
          ffmpeg
          mpv
          yt-dlp
          maim # for dm-maim
          slop # for dm-maim/dm-record selections
          mpc
          mpd # for dm-music
          easyeffects # for dm-eq-profiles

          # Document/Image Viewers
          zathura # for dm-documents
          imv # for dm-setbg
          sxiv # for dm-setbg

          # Background/Wallpaper
          xwallpaper
          swaybg
          betterlockscreen

          # Misc / Script specific
          jq # for dm-websearch, dm-ip, dm-pipewire
          yad # for dm-weather
          man-db # for dm-man
          udisks2 # for dm-usbmount
          translate-shell # for dm-dictionary/dm-translate
          sqlite # for dm-bookman
          bc

          didyoumean
        ];

      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "dmscripts";
          version = "git";

          src = ./.;

          nativeBuildInputs = with pkgs; [
            makeWrapper
            pandoc
          ];

          installPhase = ''
            mkdir -p $out/bin $out/share/dmscripts
            cp -r scripts/* $out/bin/
            chmod +x $out/bin/*
            cp config/config $out/share/dmscripts/config

            # Patch scripts to use the absolute store path for the helper
            for script in $out/bin/dm-*; do
              substituteInPlace "$script" \
                --replace "source ./_dm-helper.sh" "source $out/bin/_dm-helper.sh" \
                --replace "source _dm-helper.sh" "source $out/bin/_dm-helper.sh"
            done

            # Point helper to the nix-provided config
            substituteInPlace $out/bin/_dm-helper.sh \
              --replace "/etc/dmscripts/config" "$out/share/dmscripts/config"
          '';

          postFixup = ''
            # don't wrap the helper, or it'll hit its guard clause
            for script in $(find $out/bin -type f -name "dm-*"); do
              wrapProgram "$script" \
                --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps}
            done
          '';
        };

        devShells.default = pkgs.mkShell {
          packages = runtimeDeps ++ [
            pkgs.shellcheck
            pkgs.shfmt
          ];
        };
      }
    );
}
