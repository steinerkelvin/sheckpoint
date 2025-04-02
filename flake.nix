{
  description = "Sheckpoint - A shell-integrated checkpoint system";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, git-hooks }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        # Create a wrapper script that makes the sheckpoint.sh executable
        sheckpoint = pkgs.writeScriptBin "sheckpoint" ''
          #!${pkgs.bash}/bin/bash
          exec ${self}/sheckpoint.sh "$@"
        '';

        buildInputs = [
          # Runtime dependencies
          pkgs.git
          pkgs.bash
        ];

        devPkgs = [
          # Development tools
          pkgs.just
          pkgs.shellcheck
        ];
      in
      {
        # Expose the sheckpoint script as an app
        apps.default = {
          type = "app";
          program = "${sheckpoint}/bin/sheckpoint";
        };

        # Make the shell script executable as a package
        packages.default = sheckpoint;

        # Pre-commit hooks configuration
        checks = {
          pre-commit-check = git-hooks.lib.${system}.run {
            src = ./.;
            hooks = {
              # Shell script checks
              shellcheck.enable = true;

              # Nix formatting
              nixpkgs-fmt.enable = true;
            };
          };
        };

        # Development shell with tools
        devShells.default = pkgs.mkShell {
          inherit buildInputs;
          packages = devPkgs;

          # Add the pre-commit hook to the shell
          inherit (self.checks.${system}.pre-commit-check) shellHook;
        };
      }
    );
}
