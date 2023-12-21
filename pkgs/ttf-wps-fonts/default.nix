{ lib
, stdenvNoCC
, fetchgit
, ...
}: stdenvNoCC.mkDerivation rec {
  pname = "ttf-wps-fonts";
  version = "1.0.0";

  src = fetchgit {
    url = "https://github.com/IamDH4/ttf-wps-fonts";
    rev = "b3e935355afcfb5240bac5a99707ffecc35772a2";
    hash = "sha256-oRVREnE3qsk4gl1W0yFC11bHr+cmuOJe9Ah+0Csplq8=";
  };

  installPhase = ''
    echo "- Install Fonts";
    install -m644 -Dt $out/share/fonts/truetype $src/*.{ttf,TTF}
    install -m644 -Dt $out/share/licenses/${pname} ${./license.txt}
  '';

  meta = with lib; {
    description = "ttf for wps office";
    platforms = platforms.all;
    license = licenses.unfree;
  };
}
