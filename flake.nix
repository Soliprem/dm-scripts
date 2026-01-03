{
  description = "Soliprem's modular dmscripts";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Default package installs everything
        packages.default = pkgs.callPackage ./modules/package.nix { 
            scripts = []; 
            displayServer = "both"; 
        };
        
        devShells.default = pkgs.mkShell {
          packages = [ pkgs.shellcheck pkgs.shfmt ];
        };
      }
    ) // {
      nixosModules.default = import ./modules/nixos-module.nix;
      homeManagerModules.default = import ./modules/home-manager-module.nix;
    };
}
