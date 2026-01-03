# Soliprem's Dmenu Scripts (dmscripts)

A fork of [DT's dmscripts](https://gitlab.com/dwt1/dmscripts) with additional Nix packaging and modular installation support.

![dmscripts](https://gitlab.com/dwt1/dmscripts/raw/master/img/logo-1920x630.png "dmscripts")

## What Makes This Fork Different?

This fork maintains compatibility with the original dmscripts project while adding:

- **Nix Flake Support**: First-class Nix integration with a proper flake
- **NixOS Module**: System-wide installation via NixOS configuration
- **Home Manager Module**: User-level installation for Home Manager
- **Modular Installation**: Install only the scripts you need
- **Display Server Filtering**: Choose X11-only, Wayland-only, or both dependencies

These additions make dmscripts easier to integrate into Nix-based workflows without modifying the core functionality of the original scripts.

## About dmscripts

Originally created by [Derek Taylor (DistroTube)](https://gitlab.com/dwt1/dmscripts), dmscripts is a collection of bash scripts designed to work with dmenu, rofi, and fzf as menu systems. The scripts provide quick access to common tasks like:

- Browser bookmark management
- System logout/shutdown/reboot
- Screenshot tools
- Wallpaper selection
- Web searches
- WiFi connection
- And many more utilities

For most scripts, simply pass `-d`, `-f`, or `-r` to select dmenu, fzf, or rofi respectively. If no option is given, dmenu is the default.

## Installation

### Using Nix Flakes

Add this flake to your system:
```nix
{
  inputs = {
    dmscripts.url = "gitlab:soliprem/dmscripts";
    # or use a specific branch/commit
  };
}
```

#### NixOS System-Wide
```nix
{
  imports = [ inputs.dmscripts.nixosModules.default ];

  programs.dmscripts = {
    enable = true;
    displayServer = "wayland";  # or "x11" or "both" (default)
    scripts = [  # Leave empty to install all
      "dm-bookman"
      "dm-colpick"
      "dm-websearch"
      # ... add only what you need
    ];
    manPages = true;  # Install man pages (default: false)
  };
}
```

#### Home Manager
```nix
{
  imports = [ inputs.dmscripts.homeManagerModules.default ];

  programs.dmscripts = {
    enable = true;
    displayServer = "wayland";
    scripts = [ ];  # Empty list installs all scripts
  };
}
```

### Traditional Installation (Arch Linux)

For non-Nix systems, follow the [original installation instructions](https://gitlab.com/dwt1/dmscripts#installation):
```bash
git clone https://gitlab.com/soliprem/dmscripts.git
cd dmscripts
makepkg -cf
sudo pacman -U *.pkg.tar.zst
```

### Other Linux Distributions
```bash
git clone https://gitlab.com/soliprem/dmscripts.git
cd dmscripts
sudo make clean build
sudo make install
```

## Configuration

Copy the config file to your user directory:
```bash
cp -riv config/ "$HOME"/.config/dmscripts
```

Edit `~/.config/dmscripts/config` to customize:
- Menu programs (dmenu, rofi, tofi, etc.)
- Applications (browser, terminal, editor, locker)
- Script-specific settings
- Custom lists and arrays

See the [Configuration section in the original README](https://gitlab.com/dwt1/dmscripts#configuration) for detailed configuration options.

## Available Scripts

All scripts from the upstream project are included:

- **dm-bookman** - Browser bookmark/quickmark/history search
- **dm-colpick** - Color picker (copy hex values)
- **dm-confedit** - Configuration file manager
- **dm-dictionary** - Dictionary lookup
- **dm-documents** - PDF file searcher
- **dm-hub** - Launch hub for all scripts
- **dm-ip** - Get IP information
- **dm-kill** - Process killer
- **dm-logout** - Logout/shutdown/reboot menu
- **dm-maim** - Screenshot utility
- **dm-man** - Man page browser
- **dm-music** - MPD music player interface
- **dm-note** - Note storage and retrieval
- **dm-radio** - Online radio player
- **dm-setbg** - Wallpaper setter
- **dm-websearch** - Multi-engine web search
- **dm-wifi** - WiFi connection manager
- **dm-youtube** - YouTube subscription manager
- And more...

Run `dm-hub` to access all scripts from a single menu.

## Nix Module Options
```nix
programs.dmscripts = {
  enable = true;             # Enable dmscripts
  displayServer = "both";    # "x11", "wayland", or "both"
  scripts = [ ];             # List of scripts to install (empty = all)
  manPages = false;          # Install man pages
};
```

## Contributing

Contributions to the Nix packaging and modules are welcome! For changes to the core scripts, please consider contributing to the [upstream project](https://gitlab.com/dwt1/dmscripts) first.

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## Credits

- **Original Author**: [Derek Taylor (DistroTube)](https://gitlab.com/dwt1)
- **Original Repository**: https://gitlab.com/dwt1/dmscripts
- **Nix Packaging**: Soliprem

This fork exists to provide better Nix integration while staying synchronized with upstream improvements.

## License

GNU GPLv3 - See [LICENSE](LICENSE)

All modifications maintain compatibility with the original license.
