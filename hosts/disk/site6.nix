{ self, lib, ... }: with lib;

imports [
  (self + /hosts/cube/acme)
  (self + /hosts/cube/matrix/well-known.nix)
  (self + /hosts/cube/nginx.nix)
  (self + /hosts/cube/site.nix)
]
