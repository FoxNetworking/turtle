{
  description = "The Turtle Discord bot";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Used to allow enumerating all systems for output packages
    flake-utils.url = "github:numtide/flake-utils";
  };

  # In summary, we define two things:
  # - an output containing our package
  #     Refer to `./nix/package.nix`!
  # - a NixOS module allowing configuration for a systemd service
  #     `./nix/service.nix` contains its logic.
  outputs = { self, flake-utils, nixpkgs }:
    # 1. Our actual package ("turtle") as an output
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        # We're currently using Node.js 22.
        #
        # When updating Turtle, please update this to match
        # the version used within the upstream repo!
        nodejsPackage = pkgs.nodejs_22;
      in
      rec {
        # Simple shell to allow development.
        devShells.default = pkgs.mkShell {
          buildInputs = [
            nodejsPackage
            nodejsPackage.pkgs.npm
            nodejsPackage.pkgs.prisma
          ];
        };

        # Our actual package is turtle.
        packages = {
          turtle = pkgs.callPackage ./nix/package.nix { inherit pkgs nodejsPackage; };
          default = self.packages.${system}.turtle;
        };

        overlays.default = self.overlay;

        formatter = pkgs.nixpkgs-fmt;
      }))
    //
    {
      # 2. Our NixOS module defining our service and config.
      nixosModules.default = import ./nix/service.nix { inherit self; };
    };
}
