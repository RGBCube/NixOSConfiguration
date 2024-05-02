{ lib, ... }: with lib;

let
  userOptions.options.isDesktopUser = mkOption {
    type    = types.bool;
    default = false;
  };
in options {
  users.users = mkOption {
    type = with types; attrsOf (submodule userOptions);
  };
}
