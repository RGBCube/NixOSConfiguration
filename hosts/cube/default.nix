{ config, lib, keys, ... }: with lib; merge

(systemConfiguration {
  system.stateVersion  = "23.05";
  nixpkgs.hostPlatform = "x86_64-linux";

  networking.domain = "rgbcu.be";

  secrets.rgbPassword.file = ./password.rgb.age;

  users.users = {
    root.hashedPasswordFile = config.secrets.rgbPassword.path;

    rgb = sudoUser {
      description                 = "RGB";
      openssh.authorizedKeys.keys = [ keys.enka ];
      hashedPasswordFile          = config.secrets.rgbPassword.path;
    };
  };

  services.openssh.banner = ''
     _______________________________________
    / If God doesn't destroy San Francisco, \
    | He should apologize to Sodom and      |
    \ Gomorrah.                             /
     ---------------------------------------
            \   ^__^
             \  (oo)\_______
                (__)\       )\/\
                    ||----w |
                    ||     ||
  '';
})

(homeConfiguration {
  home.stateVersion = "23.11";
})
