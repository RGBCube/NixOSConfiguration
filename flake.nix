{
  description = "RGBCube's NixOS Configuration Collection";

  nixConfig = {
    extra-substituters        = "https://cache.garnix.io/";
    extra-trusted-public-keys = "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g=";
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    homeManager = {
      url = "github:nix-community/home-manager";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    ageNix = {
      url = "github:ryantm/agenix";

      inputs.nixpkgs.follows      = "nixpkgs";
      inputs.home-manager.follows = "homeManager";
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
    self,
    nixpkgs,
    ageNix,
    simpleMail,
    homeManager,
    ghosttyModule,
    ...
  } @ inputs: let
    lib0 = nixpkgs.lib;
    keys = import ./keys.nix;

    collectNixFiles = directory: with lib0; pipe (builtins.readDir directory) [
      (mapAttrsToList (name: type: let
        path = /${directory}/${name};
      in if type == "directory" then
        collectNixFiles path
      else
        path))
      flatten
      (filter (hasSuffix ".nix"))
      (filter (name: !hasPrefix "_" (builtins.baseNameOf name)))
    ];

    lib1 = with lib0; extend (_: _: pipe (collectNixFiles ./lib) [
      (map (file: import file lib0))
      (filter (thunk: !isFunction thunk))
      (foldl' recursiveUpdate {})
    ]);

    nixpkgsOverlayModule = with lib1; {
      nixpkgs.overlays = [(final: prev: {
        ghostty = inputs.ghostty.packages.${prev.system}.default;
        zls     = inputs.zls.packages.${prev.system}.default;
      })] ++ pipe inputs [
        attrValues
        (filter (value: value ? overlays.default))
        (map (value: value.overlays.default))
      ];
    };

    homeManagerModule = { lib, ... }: with lib; {
      home-manager.users = genAttrs allNormalUsers (_: {});

      home-manager.useGlobalPkgs   = true;
      home-manager.useUserPackages = true;

      home-manager.sharedModules = [ ghosttyModule.homeModules.default ];
    };

    optionModules = [
      homeManager.nixosModules.default
      ageNix.nixosModules.default
      simpleMail.nixosModules.default

      (lib1.mkAliasOptionModule [ "secrets" ] [ "age" "secrets" ])
    ] ++ collectNixFiles ./options;

    optionUsageModules = [
      nixpkgsOverlayModule
      homeManagerModule
    ] ++ collectNixFiles ./modules;

    specialArgs = { inherit self inputs keys; };

    hosts = lib1.pipe (builtins.readDir ./hosts) [
      (lib1.filterAttrs (name: type: type == "regular" -> lib1.hasSuffix ".nix" name))
      lib1.attrNames
    ];

    lib2s = with lib1; genAttrs hosts (name: let
      hostStub = nixosSystem {
        inherit specialArgs;

        modules = [ ./hosts/${name} ] ++ optionModules;
      };
    in extend (_: _: pipe (collectNixFiles ./lib) [
      (map (file: import file lib1))
      (filter (isFunction))
      (map (func: func hostStub.config))
      (foldl' recursiveUpdate {})
    ]));

    configurations = lib1.genAttrs hosts (name: lib2s.${name}.nixosSystem {
      inherit specialArgs;
 
      modules = [{
        networking.hostName = name;
      }] ++ optionModules ++ optionUsageModules ++ collectNixFiles ./hosts/${name};
    });
  in {
    nixosConfigurations = configurations;

  # This is here so we can do self.<whatever> instead of self.nixosConfigurations.<whatever>.config.
  } // lib1.mapAttrs (_: value: value.config) configurations;
}
