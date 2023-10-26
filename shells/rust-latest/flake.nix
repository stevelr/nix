# nix dev environment with rust (rustc,cargo,rustfmt,cargo-clippy), rust-analyzer
# start shell 'nix develop'
{
  description = "devShell for rust development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-utils.follows = "flake-utils";
      };
    };
  };

  outputs = {
    self,
    nixpkgs,
    rust-overlay,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        overlays = [(import rust-overlay)];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
        # use latest rust toolchain, and rust-src extension for rust-analyzer
        rust = pkgs.rust-bin.stable.latest.default.override {
          extensions = ["rust-src"];
          # add additional targets if needed:
          # targets = ["wasm32-unknown-unknown" "wasm32-wasi"];
        };
      in {
        devShells.default = pkgs.mkShell {
          buildInputs =
            (with pkgs; [
              openssl
              pkg-config
              rust-analyzer
            ])
            ++ [
              rust
            ];

          shellHook = ''
            echo "Entering rust-latest shell"
            rustc --version
            exec zsh
          '';
        };
      }
    );
}
