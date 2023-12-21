{ stdenvNoCC
, lib
, fetchurl
, p7zip
  # TODO: make options for language
}:
let
  baseURL = "http://software-static.download.prss.microsoft.com/pr/download/";
  isofile = "19042.631.201119-0144.20h2_release_svc_refresh_CLIENTENTERPRISEEVAL_OEMRET_x86FRE_en-us.iso";
  isoURL = baseURL + isofile;
in
stdenvNoCC.mkDerivation rec {
  pname = "ttf-ms-win10";
  version = "19042.631.201119-0144";

  src = fetchurl {
    name = "ms-win10-fonts";
    url = isoURL;
    hash = "sha256-jf9x57yTJRR53Wqu4GSHoLT3DLT91JiU+ZlwfrwYZKc=";
    downloadToTemp = true;
    recursiveHash = true;
    postFetch = /* bash */ ''
      _out=$TEMPDIR/out
      mkdir -p $_out
      mkdir -p $_out/fonts
      mv $downloadedFile $_out/win.iso
      echo "- Extracting Windows installation image"
      echo " - Extracting file from local Windows installation image."
      7z -aoa -bb3 -o$_out e $_out/win.iso sources/install.wim
      echo " - Extracting ttf"
      7z -aoa -bb3 -o$_out/fonts e $_out/install.wim \
      Windows/{Fonts/"*".{ttf,ttc},System32/Licenses/neutral/"*"/"*"/license.rtf}

      mkdir -p $out

      mv $_out/fonts/* $out/
      # delete files
      rm -rf $_out
    '';
    nativeBuildInputs = [ p7zip ];
  };

  installPhase = ''
    ls $src/
    echo "- Install fonts."
    install -m644 -Dt $out/share/fonts/truetype $src/*.{ttf,ttc}
    echo "- Install Licenses."
    install -m644 -Dt $out/share/licenses/${pname} $src/license.rtf
  '';

  meta = with lib;
    {
      description = "ttf from Windows 10 LSTC";
      homepage = "http://www.microsoft.com/typography/fonts/product.aspx?PID=164";
      platforms = platforms.all;
      license = licenses.unfree;
    };
}
