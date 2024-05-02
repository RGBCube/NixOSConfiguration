{ config, lib, pkgs, ... }: with lib; imports [

(desktopSystemConfiguration {
  console = {
    earlySetup = true;
    font       = "Lat2-Terminus16";
    packages   = with pkgs; [ terminus_font ];
  };
})

(desktopSystemFonts [
  config.theme.font.sans.package
  config.theme.font.mono.package

  pkgs.noto-fonts
  pkgs.noto-fonts-cjk-sans
  pkgs.noto-fonts-lgc-plus
  pkgs.noto-fonts-emoji
])

(serverSystemConfiguration {
  fonts.fontconfig = disabled;
})

]
