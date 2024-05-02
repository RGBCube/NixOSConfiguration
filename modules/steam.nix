{ lib, pkgs, ... }: with lib; imports [

(desktopSystemConfiguration {
  # Steam uses 32-bit drivers for some unholy fucking reason.
  hardware.opengl.driSupport32Bit = true;

  nixpkgs.config.allowUnfree = true;
})

(desktopUserHomePackages (with pkgs; [
  steam
]))

]
