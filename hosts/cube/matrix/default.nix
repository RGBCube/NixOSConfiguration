{ config, lib, ... }: with lib;

let
  inherit (config.networking) domain;

  chatDomain = "chat.${domain}";
  syncDomain = "sync.${domain}";

  notFoundLocationConfig = config.siteRootConfig // {
    locations."/".extraConfig = "return 404;";

    locations."/assets/".extraConfig = "return 301 https://${domain}$request_uri;";
  };

  synapsePort = 8002;
  syncPort    = 8003;
in serverSystemConfiguration {
  secrets.matrixSecret = {
    file  = ./password.secret.age;
    owner = "matrix-synapse";
  };
  secrets.matrixSyncPassword = {
    file  = ./password.sync.age;
    owner = "matrix-synapse";
  };

  services.postgresql = {
    ensureDatabases = [ "matrix-synapse" "matrix-sliding-sync" ];
    ensureUsers     = [
      {
        name = "matrix-synapse";
        ensureDBOwnership = true;
      }
      {
        name = "matrix-sliding-sync";
        ensureDBOwnership = true;
      }
    ];
  };

  services.matrix-synapse = enabled {
    withJemalloc = true;

    configureRedisLocally  = true;
    settings.redis.enabled = true;

    extras = [ "postgres" "url-preview" "user-search" ];

    log.root.level = "WARNING"; # Shut the fuck up.

    settings = {
      server_name = domain;
      # We are not setting web_client_location since the root is not accessible
      # from the outside web at all. Only /_matrix is reverse proxied to.

      database.name  = "psycopg2";

      report_stats = false;

      enable_metrics = true;
      metrics_flags.known_servers = true;

      expire_access_token = true;
      url_preview_enabled = true;

      # Trusting Matrix.org.
      suppress_key_server_warning = true;
    };

    # Sets registration_shared_secret.
    extraConfigFiles = [ config.secrets.matrixSecret.path ];

    settings.listeners = [{
      port = synapsePort;

      bind_addresses = [ "::1" ];
      tls            = false;
      type           = "http";
      x_forwarded    = true;

      resources = [{
        compress = false;
        names    = [ "client" "federation" ];
      }];
    }];
  };

  services.nginx.virtualHosts.${chatDomain} = mergeAttrs config.sslTemplate config.wellKnownResponseConfig notFoundLocationConfig {
    locations."/_matrix".proxyPass         = "http://[::1]:${toString synapsePort}";
    locations."/_synapse/client".proxyPass = "http://[::1]:${toString synapsePort}";
  };

  services.matrix-sliding-sync = enabled {
    environmentFile = config.age.secrets.matrixSyncPassword.path;
    settings        = {
      SYNCV3_SERVER   = "https://${chatDomain}/";
      SYNCV3_DB       = "postgresql:///matrix-sliding-sync?host=/run/postgresql";
      SYNCV3_BINDADDR = "[::1]:${toString syncPort}";
    };
  };

  services.nginx.virtualHosts.${syncDomain} = mergeAttrs config.sslTemplate config.wellKnownResponseConfig notFoundLocationConfig {
    locations."~ ^/(client/|_matrix/client/unstable/org.matrix.msc3575/sync)"
      .proxyPass = "http://[::1]:${toString synapsePort}";

    locations."~ ^(\\/_matrix|\\/_synapse\\/client)"
      .proxyPass = "http://[::1]:${toString syncPort}";
  };
}
