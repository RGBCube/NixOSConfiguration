{ config, lib, ... }: with lib; imports [

(systemConfiguration {
  system.stateVersion  = "23.05";
  nixpkgs.hostPlatform = "x86_64-linux";

  time.timeZone = "Europe/Istanbul";

  secrets = {
    orhanPassword.file = ./password.orhan.age;
    saidPassword.file  = ./password.said.age;
  };

  users.users = {
    root.hashedPasswordFile = config.secrets.saidPassword.path;

    orhan = desktopUser {
      description        = "Orhan";
      hashedPasswordFile = config.secrets.orhanPassword.path;
    };

    said = sudoUser (desktopUser {
      description        = "Said";
      hashedPasswordFile = config.secrets.saidPassword.path;
    });
  };
})

(homeConfiguration {
  home.stateVersion = "23.05";
})

]
