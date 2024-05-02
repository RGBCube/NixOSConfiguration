{ config, lib, keys, ... }: with lib; imports [

(systemConfiguration {
  system.stateVersion  = "23.05";
  nixpkgs.hostPlatform = "x86_64-linux";

  secrets.id.file          = ./id.age;
  secrets.rgbPassword.file = ./password.rgb.age;

  users.users = {
    root.hashedPasswordFile = config.secrets.rgbPassword.path;

    rgb = sudoUser {
      description                 = "RGB";
      openssh.authorizedKeys.keys = [ keys.enka ];
      hashedPasswordFile          = config.secrets.rgbPassword.path;
    };
  };

  services.openssh = {
    banner = ''
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

    hostKeys = [{
      type = "ed25519";
      path = config.secrets.id.path;
    }];
  };

  networking = {
    ipv4 = "5.255.78.70";

    domain = "rgbcu.be";
  };
})

(homeConfiguration {
  home.stateVersion = "23.11";
})

]
