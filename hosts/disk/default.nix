{ config, lib, keys, ... }: with lib; imports [

(systemConfiguration {
  system.stateVersion  = "23.11";
  nixpkgs.hostPlatform = "x86_64-linux";

  secrets.id.file              = ./id.age;
  secrets.floppyPassword.file  = ./password.floppy.age;

  users.users = {
    root.hashedPasswordFile = config.secrets.floppyPassword.path;

    floppy = sudoUser {
      description                 = "Floppy";
      openssh.authorizedKeys.keys = [ keys.enka ];
      hashedPasswordFile          = config.secrets.floppyPassword.path;
    };

    backup = normalUser {
      description                 = "Backup";
      openssh.authorizedKeys.keys = [ keys.cube keys.enka ];
      hashedPasswordFile          = config.secrets.floppyPassword.path;
    };
  };

  services.openssh.hostKeys = [{
    type = "ed25519";
    path = config.secrets.id.path;
  }];

  networking = {
    ipv4 = "23.164.232.40";
    ipv6 = "2602:f9f7::40";

    domain = "rgbcu.be";

    defaultGateway  = "23.164.232.1";
    defaultGateway6 = "2602:f9f7::1";

    interfaces.ens32 = {
      ipv4.addresses = [{
        address      = config.networking.ipv4;
        prefixLength = 25;
      }];

      ipv6.addresses = [{
        address      = config.networking.ipv6;
        prefixLength = 64;
      }];
    };
  };
})

(homeConfiguration {
  home.stateVersion = "23.11";
})

]
