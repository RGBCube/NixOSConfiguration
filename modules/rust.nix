{ lib, pkgs, ... }: with lib; imports [

(desktopSystemPackages (with pkgs; [
  cargo-expand

  (fenix.complete.withComponents [
    "cargo"
    "clippy"
    "rust-src"
    "rustc"
    "rustfmt"
  ])
]))

(desktopSystemConfiguration {
  environment.variables.CARGO_NET_GIT_FETCH_WITH_CLI = "true";
})

]
