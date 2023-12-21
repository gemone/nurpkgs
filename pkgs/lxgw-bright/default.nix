{ lib, stdenvNoCC, fetchurl, p7zip }:

stdenvNoCC.mkDerivation rec {
  pname = "lxgw-bright";
  version = "5.300";

  src = fetchurl {
    url = "https://github.com/lxgw/LxgwBright/releases/download/v${version}/LXGWBright.7z";
    hash = "sha256-logkVjEaH0MEu+RGACr+1w82WYXCtNI4IkxbqsGjkJs=";
  };

  nativeBuildInputs = [ p7zip ];

  sourceRoot = ".";
  unpackCmd = "7z x $src";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/fonts/truetype
    mkdir -p $out/share/fonts/opentype
    mv LXGWBright/*.ttf $out/share/fonts/truetype
    mv LXGWBright/*.otf $out/share/fonts/opentype

    runHook postInstall
  '';

  meta = with lib; {
    homepage = "https://lxgw.github.io/";
    description = "An open-source Chinese font derived from Fontworks' Klee One";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [ elliot ];
  };
}
