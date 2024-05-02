{ config, lib, ... }: with lib;

options {
  sslTemplate = mkConst {
    forceSSL    = true;
    quic        = true;
    useACMEHost = config.networking.domain;
  };
}
