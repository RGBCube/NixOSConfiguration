{ config, lib, ... }: {
  options = lib.mapAttrs (_: lib.mkValue) {
    isDesktop = lib.pipe config.users.users [
      lib.attrValues
      (lib.getAttr "extraGroups")
      (lib.elem "graphical")
      lib.any
    ];

    isServer = !config.isDesktop;

    mkPkgs  = pkgs: { environment.systemPackages = pkgs; };
    mkFonts = fonts: { fonts.packages = fonts; };

    mkHome          = cfg: { home-manager.sharedModules = [ cfg ]; };
    mkGraphicalHome = cfg: { config, ... }: let
      graphicalUsers = lib.pipe config.users.users [
        (lib.filterAttrs (_: value: lib.elem "graphical" value.extraGroups))
        lib.attrNames
      ];
    in { home-manager.users = lib.genAttrs graphicalUsers (_: cfg); };

    mkIfDesktop = { config = lib.mkIf config.isDesktop; };
    mkIfServer  = { config = lib.mkIf config.isServer; };
  };
}
