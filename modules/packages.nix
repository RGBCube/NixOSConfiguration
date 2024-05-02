{ lib, pkgs, ... }: with lib; imports [

(systemPackages (with pkgs; [
  asciinema
  cowsay
  curlHTTP3
  dig
  fastfetch
  fd
  (fortune.override { withOffensive = true; })
  hyperfine
  moreutils
  openssl
  p7zip
  pstree
  rsync
  strace
  timg
  tree
  usbutils
  uutils-coreutils-noprefix
  yazi
  yt-dlp
]))

(desktopSystemPackages (with pkgs; [
  clang_16
  clang-tools_16
  deno
  gh
  go
  jdk
  lld
  maven
  vlang
  zig

  wine
]))

(desktopUserHomePackages (with pkgs; [
  element-desktop
  fractal
  qbittorrent
  thunderbird
  whatsapp-for-linux

  krita
  obs-studio

  libreoffice
  hunspellDicts.en_US
  hunspellDicts.en_GB-ize
]))

]
