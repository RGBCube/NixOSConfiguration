{ lib, ... }: with lib;

options {
  networking = {
    ipv4 = mkValue null;
    ipv6 = mkValue null;
  };
}
