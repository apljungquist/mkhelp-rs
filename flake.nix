{
  description = "Support for docstrings in makefiles";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      flake-utils,
      nixpkgs,
      rust-overlay,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:

      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ rust-overlay.overlays.default ];
        };
        rustToolchain = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
        mkhelp = pkgs.callPackage ./package.nix { };
      in
      {
        formatter = pkgs.nixfmt-rfc-style;

        packages.default = pkgs.callPackage ./package.nix { };

        devShells.default = pkgs.mkShellNoCC {
          nativeBuildInputs = with pkgs; [
            mkhelp
            rustToolchain
          ];

          packages = with pkgs; [
            nixfmt-rfc-style
          ];

          shellHook = ''
            # Prevent cargo from finding programs in the default cargo home by **appending** it to the path because
            # otherwise cargo will **prepend** it to the path e.g. when looking for clippy.
            export PATH="$PATH:$HOME/.cargo/bin"
            # Tell rust-analyzer where to find the standard library
            export RUST_SRC_PATH="${rustToolchain}/lib/rustlib/src/rust/library"
          '';
        };
      }
    );
}
