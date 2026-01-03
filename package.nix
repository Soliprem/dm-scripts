{
  lib,
  stdenv,
  makeWrapper,
  pkgs,
  scripts ? [ ],
  displayServer ? "both",
}:

let
  # --- Dependency Definitions ---
  scriptDeps = {
    dm-bookman = [ pkgs.sqlite ];
    dm-colpick = [ ];
    dm-confedit = [ ];
    dm-dictionary = with pkgs; [
      translate-shell
      didyoumean
    ];
    dm-documents = with pkgs; [ zathura ];
    dm-eq-profiles = with pkgs; [ easyeffects ];
    dm-hub = [ ];
    dm-ip = with pkgs; [
      bind
      iproute2
      jq
    ];
    dm-kill = with pkgs; [ procps ];
    dm-lights = with pkgs; [ light ];
    dm-logout = with pkgs; [
      systemd
      libnotify
    ];
    dm-maim = with pkgs; [
      maim
      slop
      xdotool
      xorg.xrandr
    ];
    dm-man = with pkgs; [ man-db ];
    dm-music = with pkgs; [
      mpc
      mpd
    ];
    dm-note = [ ];
    dm-pipewire-out-switcher = with pkgs; [
      jq
      pulseaudio
    ];
    dm-radio = with pkgs; [
      mpv
      yt-dlp
    ];
    dm-record = with pkgs; [
      ffmpeg
      pulseaudio
      slop
    ];
    dm-reddit = with pkgs; [ yad ];
    dm-rice = with pkgs; [ gnumake ];
    dm-setbg = with pkgs; [ imv ];
    dm-sounds = with pkgs; [ mpv ];
    dm-spellcheck = with pkgs; [ didyoumean ];
    dm-usbmount = [ pkgs.udisks2 ];
    dm-weather = with pkgs; [
      curl
      yad
    ];
    dm-websearch = with pkgs; [ jq ];
    dm-wifi = with pkgs; [ networkmanager ];
    dm-wiki = with pkgs; [ arch-wiki-docs ];
    dm-youtube = with pkgs; [ curl ];
  };

  displayDeps = {
    x11 = with pkgs; [
      xclip
      xwallpaper
      sxiv
      xorg.xrandr
    ];
    wayland = with pkgs; [
      wl-clipboard
      swaybg
      imv
    ];
    both = displayDeps.x11 ++ displayDeps.wayland;
  };

  baseDeps = with pkgs; [
    coreutils
    gnused
    gnugrep
    gawk
    findutils
    bash
    dmenu
    libnotify
  ];

  # --- Selection Logic ---
  # If scripts is empty/null, default to ALL scripts
  selectedScripts = if scripts == [ ] then (builtins.attrNames scriptDeps) else scripts;

  selectedScriptDeps = lib.concatMap (name: scriptDeps.${name} or [ ]) selectedScripts;
  selectedDisplayDeps = displayDeps.${displayServer};

  finalRuntimeDeps = baseDeps ++ selectedScriptDeps ++ selectedDisplayDeps;

in
stdenv.mkDerivation {
  pname = "dmscripts-custom";
  version = "custom";
  src = ./.;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/share/dmscripts

    # Always install the helper
    cp scripts/_dm-helper.sh $out/bin/

    # Install selected scripts
    ${lib.concatMapStringsSep "\n" (name: "cp scripts/${name} $out/bin/") selectedScripts}

    chmod +x $out/bin/*
    cp config/config $out/share/dmscripts/config

    # --- Boilerplate Reduction & Path Patching ---

    # 1. Point helper to the nix config
    substituteInPlace $out/bin/_dm-helper.sh \
      --replace "/etc/dmscripts/config" "$out/share/dmscripts/config"

    # 2. Point all scripts to the absolute helper path
    for script in $out/bin/*; do
      substituteInPlace "$script" \
        --replace 'source "_dm-helper.sh"' "source $out/bin/_dm-helper.sh" \
        --replace 'source ./_dm-helper.sh' "source $out/bin/_dm-helper.sh"
    done
  '';

  postFixup = ''
    for script in $out/bin/*; do
      if [[ "$(basename $script)" != "_dm-helper.sh" ]]; then
        wrapProgram $script \
          --prefix PATH : ${lib.makeBinPath finalRuntimeDeps}
      fi
    done
  '';
}
