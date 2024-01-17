{ config, ulib, ... }: with ulib;

let
  inherit (config.networking) domain;

  chatDomain = "chat.${domain}";

  wellKnownResponse = data: ''
    add_header Content-Type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${builtins.toJSON data}';
  '';

  clientConfig."m.homeserver".base_url = chatDomain;
  serverConfig."m.server" = "${chatDomain}:443";

  synapsePort     = 8001;
  slidingSyncPort = 8002;
  exporterPort    = 9060;
in serverSystemConfiguration {
  age.secrets."cube/password.secret.matrix-synapse".owner = "matrix-synapse";
  age.secrets."cube/password.sync.matrix-synapse".owner   = "matrix-synapse";

  services.prometheus = {
    scrapeConfigs = [{
      job_name     = "matrix-synapse";
      metrics_path = "/_synapse/metrics";

      static_configs = [{
        labels.job = "matrix-synapse";
        targets    = [
          "[::]:${toString exporterPort}"
        ];
      }];
    }];
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

    settings = {
      server_name = domain;
      # We are not setting web_client_location since the root is not accessible
      # from the outside web at all. Only /_matrix is reverse proxied to.

      database.name  = "psycopg2";

      report_stats = false;

      enable_metrics = true;
      metrics_flags.known_servers = true;

      allow_guest_access  = false;
      enable_registration = false;

      expire_access_token = true;
      url_preview_enabled = true;

      # Trusting Matrix.org.
      suppress_key_server_warning = true;
    };

    # Sets registration_shared_secret.
    extraConfigFiles = [ config.age.secrets."cube/password.secret.matrix-synapse".path ];

    settings.listeners = [
      {
        port = synapsePort;

        bind_addresses = [ "::" ];
        tls            = false;
        type           = "http";
        x_forwarded    = true;

        resources = [{
          compress = false;
          names    = [ "client" "federation" ];
        }];
      }
      {
        port           = exporterPort;

        bind_addresses = [ "::" ];
        tls            = false;
        type           = "metrics";

        resources = [];
      }
    ];
  };

  services.matrix-sliding-sync = enabled {
    settings = {
      SYNCV3_SERVER   = "https://${chatDomain}";
      SYNCV3_DB       = "postgresql:///matrix-sliding-sync?host=/run/postgresql";
      SYNCV3_BINDADDR = "[::]:${toString slidingSyncPort}";
    };
    environmentFile = config.age.secrets."cube/password.sync.matrix-synapse".path;
  };

  services.nginx.virtualHosts.${domain}.locations =  {
    "= /.well-known/matrix/client".extraConfig = wellKnownResponse clientConfig;
    "= /.well-known/matrix/server".extraConfig = wellKnownResponse serverConfig;
  };

  services.nginx.virtualHosts.${chatDomain} = {
    forceSSL    = true;
    useACMEHost = domain;

    locations."/".proxyPass       = "http://[::]:${toString config.services.site.port}/404";
    locations."/assets".proxyPass = "http://[::]:${toString config.services.site.port}/assets";

    locations."= /.well-known/matrix/client".extraConfig = wellKnownResponse clientConfig;
    locations."= /.well-known/matrix/server".extraConfig = wellKnownResponse serverConfig;

    locations."/_matrix".proxyPass         = "http://[::]:${toString synapsePort}";
    locations."/_synapse/client".proxyPass = "http://[::]:${toString synapsePort}";
  };
}