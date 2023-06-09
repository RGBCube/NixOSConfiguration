{ lib, pkgs, systemConfiguration, systemFonts, ... }: lib.recursiveUpdate

(systemConfiguration {
  console = {
    earlySetup = true;
    font       = "Lat2-Terminus16";
    packages   = with pkgs; [ terminus-nerdfont ];
  };
})

(with pkgs; systemFonts [
  (nerdfonts.override {
    fonts = [ "JetBrainsMono" ];
  })
])
