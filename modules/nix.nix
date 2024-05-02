{ inputs, lib, pkgs, ... }: with lib; imports [

(systemConfiguration {
  environment.etc."flakes.json".text = strings.toJSON inputs;

  nix = {
    gc = {
      automatic  = true;
      dates      = "daily";
      options    = "--delete-older-than 3d";
      persistent = true;
    };

    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    optimise.automatic = true;

    registry = {
      default.flake = inputs.nixpkgs;
    } // mapAttrs (_: value: mkIf (isType "flake" value) {
      flake = value;
    }) inputs;

    settings.experimental-features = [
      "auto-allocate-uids"
      "ca-derivations"
      "cgroups"
      "flakes"
      "nix-command"
      "recursive-nix"
      "repl-flake"
    ];

    settings = {
      accept-flake-config      = true;
      builders-use-substitutes = true;
      flake-registry           = ""; # I DON'T WANT THE GLOBAL REGISTRY!!!
      http-connections         = 50;
      show-trace               = true;
      trusted-users            = [ "root" "@wheel" ];
      use-cgroups              = true;
      warn-dirty               = false;
    };
  };

  programs.nix-ld = enabled;
})

(systemPackages (with pkgs; [
  nh
  nix-index
  nix-output-monitor
]))

(homeConfiguration {
  programs.nushell.configFile.text = mkAfter ''
    def --wrapped nr [program: string = "", ...arguments] {
      if ($program | str contains "#") or ($program | str contains ":") {
        nix run $program -- ...$arguments
      } else {
        nix run ("default#" + $program) -- ...$arguments
      }
    }

  def --wrapped ns [...programs] {
    nix shell ...($programs | each {
      if ($in | str contains "#") or ($in | str contains ":") {
        $in
      } else {
        "default#" + $in
      }
    })
  }
  '';
})

]
