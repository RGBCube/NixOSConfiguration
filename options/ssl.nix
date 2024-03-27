{ config, lib, ... }: {
  options.sslTemplate = lib.mkValue {
    forceSSL    = true;
    quic        = true;
    useACMEHost = config.networking.domain;
  };
}
