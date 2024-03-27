lib: {
  mkValue = value: lib.mkOption {
    default  = value;
    readOnly = true;
  };

  mkValueDefault = default: lib.mkOption { inherit default; };

  enabled = x: x // {
    enable = true;
  };

  normalUser = x: x // {
    isNormalUser = true;
  };

  systemUser = x: x // {
    isSystemUser = true;
  };

  graphicalUser = x: x // {
    isNormalUser = true;
    extraGroups  = [ "graphical" ] ++ x.extraGroups or []; 
  };
}
