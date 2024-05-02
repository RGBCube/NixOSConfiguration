{ config, lib, ... }: with lib; imports [

(options {
  site.path = mkConst "/var/www/site";

  site.nginxRootConfiguration = mkConst {
    root = config.site.path;

    extraConfig = ''
      error_page 404 /404.html;
    '';

    locations."/404".extraConfig = ''
      internal;
    '';
  };
})

(let
  inherit (config.networking) domain;
in systemConfiguration {
  services.nginx = enabled {
    appendHttpConfig = ''
      map $http_origin $allow_origin {
        ~^https://.+\.${domain}$ $http_origin;
      }

      map $http_origin $allow_methods {
        ~^https://.+\.${domain}$ "GET, HEAD, OPTIONS";
      }
    '';

    virtualHosts.${domain} = mergeAttrs config.sslTemplate config.siteRootConfig {
      locations."/".tryFiles = "$uri $uri.html $uri/index.html =404";

      locations."/assets/".extraConfig = ''
        add_header Access-Control-Allow-Origin $allow_origin;
        add_header Access-Control-Allow-Methods $allow_methods;

        if ($request_method = OPTIONS) {
          add_header Content-Type text/plain;
          add_header Content-Length 0;
          return 204;
        }

        expires 24h;
      '';
    };

    virtualHosts."www.${domain}" = mergeAttrs config.sslTemplate {
      locations."/".extraConfig = "return 301 https://${domain}$request_uri;";
    };

    virtualHosts._ = mergeAttrs config.sslTemplate config.siteRootConfig {
      locations."/".extraConfig        = "return 404;";
      locations."/assets/".extraConfig = "return 301 https://${domain}$request_uri;";
    };
  };
})

]
