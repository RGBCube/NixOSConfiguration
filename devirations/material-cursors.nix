{ lib, pkgs, stdenvNoCC, fetchFromGitHub }:

stdenvNoCC.mkDerivation {
  pname   = "material-cursors";
  version = "2023-11-30";

  src = fetchFromGitHub {
    owner = "varlesh";
    repo  = "material-cursors";
    rev   = "2a5f302fefe04678c421473bed636b4d87774b4a";
    hash  = "sha256-uC2qx3jF4d2tGLPnXEpogm0vyC053MvDVVdVXX8AZ60=";
  };

  nativeBuildInputs = with pkgs; [
    inkscape
    xorg.xcursorgen
  ];

  buildPhase = ''
    runHook preBuild

    HOME=$(pwd) bash build.sh 2> /dev/null

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/icons
    cp -r dist/* $out/share/icons/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Material cursors for Linux";
    homepage    = "https://github.com/varlesh/material-cursors";
    license     = licenses.gpl3;
    platforms   = platforms.linux;
    maintainers = with maintainers; [
      RGBCube
    ];
  };
}