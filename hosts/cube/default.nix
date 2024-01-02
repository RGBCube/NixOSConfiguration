{ ulib, ... }: with ulib; merge

(systemConfiguration {
  system.stateVersion = "23.05";

  nixpkgs.hostPlatform = "x86_64-linux";

  time.timeZone = "Europe/Amsterdam";

  # HACK: Makes HM see the user. Idk how to automate that.
  home-manager.users.rgb = {};
  users.users.rgb = normalUser {
    description = "RGB";
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDRSLWxpIMOZIQv9ggDnAwSxmux/TZvuEPgq2HFiH+oI2OE07xYQAiroBVI5HH+aIg1nwpYtArANoD8V9Hrx2XCo2py/fMi9LhJWNMlFVcRLqYrCmrZYhBqZhxXIdY+wXqkSE7kvTKsz84BrhwilfA/bqTgVw2Ro6w0RnTzUhlYx4w10DT3isN09cQJMgvuyWNRlpGpkEGhPwyXythKM2ERoHTfq/XtpiGZQeLr6yoTTd9q4rbvnGGka5IUEz3RrmeXEs13l02IY6dCUFJkRRsK8dvB9zFjQyM08IqdaoHeudZoCOsnl/AiegZ7C5FoYEKIXY86RqxS3TH3nwuxe2fXTNr9gwf2PumM1Yh2WxV4+pHQOksxW8rWgv1nXMT5AG0RrJxr+S0Nn7NBbzCImrprX3mg4vJqT24xcUjUSDYllEMa2ioXGCeff8cwVKK/Ly5fwj0AX1scjiw+b7jD6VvDLA5z+ALwCblxiRMCN0SOMk9/V2Xsg9YIRMHyQwpqu8k= nixos@enka" ];
  };
})

(homeConfiguration {
  home.stateVersion = "23.11";
})
