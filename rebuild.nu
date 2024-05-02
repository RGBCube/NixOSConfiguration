#!/usr/bin/env nu

def main --wrapped [
  host: string = "" # The host to build.
  ...arguments      # The arguments to pass to `nixos-rebuild switch`.
] {
  let host = if ($host | is-not-empty) {
    $host
  } else {
    (hostname)
  }

  let args_split = $arguments | split list "--"

  let nh_flags = [
    "--hostname" $host
  ] | append ($args_split | get --ignore-errors 0 | default [])

  let nix_flags = [
    "--option" "accept-flake-config" "true"
  ] | append ($args_split | get --ignore-errors 1 | default [])

  if $host == (hostname) {
    nh os switch . ...$nh_flags -- ...$nix_flags
  } else {
    git ls-files | (
      rsync
        --rsh "ssh -q"
        --delete --delete-excluded --delete-missing-args
        --compress
        --files-from -
        ./ ($host + ":Configuration")
    )

    ssh -q $host $"
      cd Configuration
      ./rebuild.nu ($host) ($arguments | str join ' ')
    "
  }
}
