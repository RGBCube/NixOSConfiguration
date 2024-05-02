{ self, config, lib, ... }: with lib; imports [

(let
  chatDomain = self.cube.services.matrix-synapse.settings.server_name;
  syncDomain = parseDomain self.cube.services.matrix-sliding-sync.settings.SYNCV3_SERVER;

  clientConfig = {
    "m.homeserver".base_url        = "https://${chatDomain}";
    "org.matrix.msc3575.proxy".url = "https://${syncDomain}";
  };

  serverConfig = {
    "m.server" = "${chatDomain}:443";
  };

  mkWellKnownResponse = data: ''
    default_type application/json;
    add_header Access-Control-Allow-Origin *;
    return 200 '${strings.toJSON data}';
  '';
in options {
  wellKnownResponseConfig = mkConst {
    locations = {
      "= /.well-known/matrix/client".extraConfig = mkWellKnownResponse clientConfig;
      "= /.well-known/matrix/server".extraConfig = mkWellKnownResponse serverConfig;
    };
  };
})

(let
  inherit (config.networking) domain;
in systemConfiguration {
  services.nginx.virtualHosts = genAttrs [ domain "_" ] (_: config.wellKnownResponseConfig);
})

]
