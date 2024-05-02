{ lib, pkgs, ... }: with lib; imports [

(systemConfiguration {
  environment.shellAliases = {
    ddg = "w3m lite.duckduckgo.com";
    web = "w3m";
  };
})

(systemPackages (with pkgs; [
  w3m
]))

]
