{ config, lib, pkgs, ... }: with lib; merge

(systemConfiguration {
  users.defaultUserShell              = pkgs.crash;
  environment.sessionVariables.SHELLS = lib.getExe pkgs.nushellFull;

  environment.shellAliases = {
    la  = "ls --all";
    lla = "ls --long --all";
    sl  = "ls";

    cp = "cp --recursive --verbose --progress";
    mk = "mkdir";
    mv = "mv --verbose";
    rm = "rm --recursive --verbose";

    pstree = "pstree -g 2";
    tree   = "tree -CF --dirsfirst";
  };
})

(homeConfiguration {
  xdg.configFile = {
    "nushell/zoxide.nu".source = pkgs.runCommand "zoxide.nu" {} ''
      ${lib.getExe pkgs.zoxide} init nushell --cmd cd > $out
    '';

    "nushell/ls_colors.txt".source = pkgs.runCommand "ls_colors.txt" {} ''
      ${lib.getExe pkgs.vivid} generate gruvbox-dark-hard > $out
    '';
  };

  programs.starship = enabled {
    settings = {
      command_timeout = 100;
      scan_timeout    = 20;

      cmd_duration.show_notifications = isDesktop;

      package.disabled = isServer;

      character.error_symbol   = "";
      character.success_symbol = "";
    };
  };

  programs.nushell = enabled {
    package = pkgs.nushellFull;

    configFile.text = readFile ./configuration.nu;
    envFile.source  = ./environment.nu;

    environmentVariables = mapAttrs (const (value: ''"${value}"'')) config.environment.variables;

    shellAliases = (attrsets.removeAttrs config.environment.shellAliases [ "ls" "l" ]) // {
      cdtmp = "cd (mktemp --directory)";
      ll    = "ls --long";
    };
  };
})

(systemPackages (with pkgs; [
  fish   # For completions.
  zoxide # For completions and better cd.
]))
