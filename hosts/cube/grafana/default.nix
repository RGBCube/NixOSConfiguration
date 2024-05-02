{ self, config, lib, ... }: with lib;

let
  inherit (config.networking) domain;

  fqdn = "metrics.${domain}";

  port = 8000;
in systemConfiguration {
  secrets.grafanaPassword = {
    file  = ./password.age;
    owner = "grafana";
  };
  secrets.grafanaMailPassword = {
    file  = self + /hosts/disk/mail/password.plain.age;
    owner = "grafana";
  };

  services.postgresql = {
    ensureDatabases = [ "grafana" ];
    ensureUsers     = [{
      name = "grafana";
      ensureDBOwnership = true;
    }];
  };

  systemd.services.grafana = {
    after    = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };

  services.grafana = enabled {
    provision = enabled;

    settings = {
      analytics.reporting_enabled = false;

      database.host = "/run/postgresql";
      database.type = "postgres";
      database.user = "grafana";

      server.domain    = fqdn;
      server.http_addr = "[::1]";
      server.http_port = port;

      users.default_theme = "system";
    };

    settings.security = {
      admin_email    = "metrics@${domain}";
      admin_password = "$__file{${config.secrets.grafanaPassword.path}}";
      admin_user     = "admin";

      cookie_secure    = true;
      disable_gravatar = true;

      disable_initial_admin_creation = true; # Just in case.
    };

    settings.smtp = {
      enabled = true;

      password        = "$__file{${config.secrets.grafanaMailPassword.path}}";
      startTLS_policy = "MandatoryStartTLS";

      ehlo_identity = "metrics@${domain}";
      from_address  = "metrics@${domain}";
      from_name     = "Metrics";
      host          = "${self.disk.mailserver.fqdn}:${toString config.services.postfix.relayPort}";
    };
  };

  services.nginx.virtualHosts.${fqdn} = mergeAttrs config.sslTemplate {
    locations."/" = {
      proxyPass       = "http://[::1]:${toString port}";
      proxyWebsockets = true;
    };
  };
}
