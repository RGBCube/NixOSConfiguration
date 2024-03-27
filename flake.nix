{
  description = "RGBCube's NixOS Configuration Collection";

  nixConfig = {
    extra-substituters        = "https://cache.garnix.io/";
    extra-trusted-public-keys = "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    nixSuper = {
      url = "github:privatevoid-net/nix-super";

      inputs.flake-compat.follows = "flakeCompat";
      # inputs.nixpkgs.follows      = "nixpkgs"; # Breaks.
    };

    homeManager = {
      url = "github:nix-community/home-manager";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    ageNix = {
      url = "github:ryantm/agenix";

      inputs.nixpkgs.follows      = "nixpkgs";
      inputs.home-manager.follows = "homeManager";
    };

    nuScripts = {
      url   = "github:nushell/nu_scripts";
      flake = false;
    };

    simpleMail = {
      url = "gitlab:simple-nixos-mailserver/nixos-mailserver";

      inputs.nixpkgs.follows      = "nixpkgs";
      inputs.utils.follows        = "flakeUtils";
      inputs.flake-compat.follows = "flakeCompat";
    };

    hyprland = {
      url = "github:hyprwm/Hyprland";

      inputs.hyprlang.follows = "hyprlang";
      inputs.nixpkgs.follows  = "nixpkgs";
      inputs.systems.follows  = "systems";
    };

    hyprpicker = {
      url = "github:hyprwm/hyprpicker";

      inputs.nixpkgs.follows  = "nixpkgs";
    };

    ghostty = {
      url = "git+ssh://git@github.com/RGBCube/ghostty";

      inputs.nixpkgs-unstable.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows   = "nixpkgs";

      inputs.zig.follows = "zig";
      inputs.zls.follows = "zig";
    };

    fenix = {
      url = "github:nix-community/fenix";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    zig = {
      url = "github:mitchellh/zig-overlay";

      inputs.nixpkgs.follows      = "nixpkgs";
      inputs.flake-utils.follows  = "flakeUtils";
      inputs.flake-compat.follows = "flakeCompat";
    };

    zls = {
      url = "github:zigtools/zls/master";

      inputs.nixpkgs.follows     = "nixpkgs";
      inputs.flake-utils.follows = "flakeUtils";
      inputs.zig-overlay.follows = "zig";
    };

    ghosttyModule.url = "github:clo4/ghostty-hm-module";

    themes.url = "github:RGBCube/ThemeNix";

    # I don't use these, but I place them here and make the other
    # inputs follow them, so I get much less duplicate code pulled in.
    flakeUtils = {
      url = "github:numtide/flake-utils";

      inputs.systems.follows = "systems";
    };

    flakeCompat = {
      url   = "github:edolstra/flake-compat";
      flake = false;
    };

    systems.url = "github:nix-systems/default";

    hyprlang = {
      url = "github:hyprwm/hyprlang";

      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "systems";
    };
  };

  outputs = {
    nixpkgs,
    ageNix,
    simpleMail,
    homeManager,
    themes,
    ...
  } @ inputs: let
    collectNixFiles = directory: with nixpkgs.lib; pipe (builtins.readDir directory) [
      attrNames
      # If it has a . in its name but doesn't end with .nix, it gets filtered.
      (filter (s: hasInfix "." s -> hasSuffix ".nix" s))
      (map (name: /${directory}/${name}))
    ];

    lib = nixpkgs.lib.extend (_: _: with nixpkgs.lib; pipe (collectNixFiles ./lib) [
      (map (file: import file nixpkgs.lib))
      (foldl' recursiveUpdate {})
    ]);

    keys = import ./keys.nix;

    nixpkgsOverlayModule = {
      nixpkgs.overlays = [(final: prev: {
        inherit (inputs) nuScripts;

        ghostty = inputs.ghostty.packages.${prev.system}.default;
        zls     = inputs.zls.packages.${prev.system}.default;
      })] ++ lib.pipe inputs [
        lib.attrValues
        (lib.filter (value: value ? overlays && value.overlays ? default))
        (map (value: value.overlays.default))
      ];
    };

    homeManagerModule = { config, ... }: {
      home-manager.users = lib.genAttrs (lib.attrNames config.users.users) (_: {});

      home-manager.useGlobalPkgs   = true;
      home-manager.useUserPackages = true;
    };

    themeModule = { lib, pkgs, ... }: {
      options.theme = lib.mkValue (themes.custom (themes.raw.gruvbox-dark-hard // {
        cornerRadius = 8;
        borderWidth  = 2;

        margin  = 6;
        padding = 8;

        font.size.normal = 12;
        font.size.big    = 18;

        font.sans.name    = "Lexend";
        font.sans.package = pkgs.lexend;

        font.mono.name    = "JetBrainsMono Nerd Font";
        font.mono.package = (pkgs.nerdfonts.override { fonts = [ "JetBrainsMono" ]; });

        icons.name    = "Gruvbox-Plus-Dark";
        icons.package = pkgs.gruvbox-plus-icons;
      }));
    };

    ageNixModule = {
      age.identityPaths = [ "/root/.ssh/id" ];
    };

    optionModules        = collectNixFiles ./options;
    # configurationModules = collectNixFiles ./modules;
    configurationModules = [];

    globalModules = [
      nixpkgsOverlayModule

      homeManager.nixosModules.default
      homeManagerModule
      themeModule

      ageNix.nixosModules.default
      ageNixModule

      simpleMail.nixosModules.default
    ] ++ optionModules ++ configurationModules;

    collectHostModules = name: [{
      networking.hostName = name;
    } ./hosts/enka];
    # }] ++ collectNixFiles ./hosts/${name};

    hosts               = lib.attrNames (builtins.readDir ./hosts);
    nixosConfigurations = lib.genAttrs hosts (name: lib.nixosSystem {
      modules = globalModules ++ collectHostModules name;

      specialArgs = { inherit inputs keys; };
    });
  in {
    inherit nixosConfigurations;

  # This is here so we can do self.enka instead of self.nixosConfigurations.enka.config.
  } // lib.mapAttrs (_: value: value.config) nixosConfigurations;
}
