{ lib, pkgs, ... }: with lib; imports [

(systemConfiguration {
  age.identityPaths = [ "/root/.ssh/id" ];
})

(desktopSystemConfiguration {
  environment.shellAliases.agenix = "agenix --identity ~/.ssh/id";
})

(desktopSystemPackages (with pkgs; [
  agenix
]))

]
