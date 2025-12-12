{
  description = "Soliprem's fork of dmscripts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
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
          procps          #  dm-kill
          
          # Network
          networkmanager  # dm-wifi
          curl
          bind            # dm-ip
          iproute2        # dm-ip
          
          # Multimedia
          ffmpeg
          mpv
          yt-dlp
          maim            # for dm-maim
          slop            # for dm-maim/dm-record selections
          mpc
          mpd             # for dm-music
          easyeffects     # for dm-eq-profiles
          
          # Document/Image Viewers
          zathura         # for dm-documents
          imv             # for dm-setbg
          sxiv            # for dm-setbg
          
          # Background/Wallpaper
          xwallpaper
          swaybg
          betterlockscreen
          
          # Misc / Script specific
          jq              # for dm-websearch, dm-ip, dm-pipewire
          yad             # for dm-weather
          man-db          # for dm-man
          udisks2         # for dm-usbmount
          translate-shell # for dm-dictionary/dm-translate
          sqlite          # for dm-bookman
          bc              
          
          didyoumean
        ];

      in
      {
        packages.default = pkgs.stdenv.mkDerivation {
          pname = "dmscripts";
          version = "git"; 

          src = ./.;

          nativeBuildInputs = with pkgs; [ makeWrapper pandoc ];

          installPhase = ''
            mkdir -p $out/bin $out/share/dmscripts

            # Install all scripts
            cp -r scripts/* $out/bin/
            chmod +x $out/bin/*

            # Install default config
            cp config/config $out/share/dmscripts/config

            # Patch the helper script to point to the nix store config
            substituteInPlace $out/bin/_dm-helper.sh \
              --replace "/etc/dmscripts/config" "$out/share/dmscripts/config"
          '';

          # Wrap all scripts with the runtime dependencies in PATH
          postFixup = ''
            for script in $out/bin/*; do
              wrapProgram $script \
                --prefix PATH : ${pkgs.lib.makeBinPath runtimeDeps}
            done
          '';
        };

        devShells.default = pkgs.mkShell {
          packages = runtimeDeps ++ [ pkgs.shellcheck pkgs.shfmt ];
        };
      }
    );
}
