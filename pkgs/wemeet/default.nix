{ stdenv
, rsync
, wayland
, fetchurl
, lib
, autoPatchelfHook
  # qt
, qtbase
, qtlocation
, qtpositioning
, qtwayland
, qtwebchannel
, qtwebengine
, qtwebsockets
, qtwebview
, qtx11extras
, dpkg
  # xorg
, libpulseaudio
, libtiff
, libXinerama
, xorg
, wrapQtAppsHook
, makeDesktopItem
}:
let
  desktopItem = makeDesktopItem {
    name = "wemeetapp";
    desktopName = "Wemeet";
    exec = "wemeetapp-x11 %u";
    icon = "wemeetapp";
    categories = [ "AudioVideo" ];
    mimeTypes = [ "x-scheme-handler/wemeet" ];
    extraConfig = {
      "Name[zh_CN]" = "腾讯会议";
    };
  };
in
stdenv.mkDerivation {
  pname = "wemeet";
  version = "3.15.1.403";

  # TODO: add update version method
  src = fetchurl
    {
      url = "https://updatecdn.meeting.qq.com/cos/da1c30b1a927cd691e4ee60aba829c88/TencentMeeting_0300000000_3.15.1.403_x86_64_default.publish.deb";
      hash = "sha512-4hXom5oo5VsQ1MnCr8vH+XO3F46fL9FGNckzBIWmJSgjU2twMr0/eD5G/ZLkdTP0SGrqwuNZJJ1MiPuPV9FOkA==";
    };

  unpackCmd = "dpkg -x $src .";
  sourceRoot = ".";

  nativeBuildInputs = [
    dpkg
    rsync
    autoPatchelfHook
    wrapQtAppsHook
  ];

  buildInputs = [
    wayland
    libtiff
    libpulseaudio
    libXinerama
    # qt
    qtbase
    qtlocation
    qtpositioning
    qtwayland
    qtwebchannel
    qtwebengine
    qtwebsockets
    qtwebview
    qtx11extras
    xorg.xrandr
  ];

  installPhase = ''
    mkdir -p "$out"
    # use system libraries instead
    # https://github.com/NickCao/flakes/blob/ca564395aad0f2cdd45649a3769d7084a8a4fb18/pkgs/wemeet/default.nix
    rsync -rv opt/ "$out/" \
      --include "wemeet/lib/libwemeet*" \
      --include "wemeet/lib/libxnn*" \
      --include "wemeet/lib/libxcast*" \
      --include "wemeet/lib/libImSDK.so" \
      --include "wemeet/lib/libui_framework.so" \
      --include "wemeet/lib/libnxui*" \
      --include "wemeet/lib/libdesktop_common.so" \
      --include "wemeet/lib/libqt_*" \
      --include "wemeet/lib/libservice_manager.so" \
      --exclude "wemeet/lib/*" \
      --exclude "wemeet/plugins" \
      --exclude "wemeet/icons" \
      --exclude "wemeet/wemeetapp.sh" \
      --exclude "wemeet/bin/Qt*"

    mkdir -p "$out/bin"
    # TODO remove IBus and Qt style workaround
    # https://aur.archlinux.org/cgit/aur.git/commit/?h=wemeet-bin&id=32fc5d3ba55649cb1143c2b8881ba806ee14b87b
        makeQtWrapper "$out/wemeet/bin/wemeetapp" "$out/bin/wemeetapp" \
      --set-default IBUS_USE_PORTAL 1 \
      --set-default QT_STYLE_OVERRIDE fusion
    makeWrapper "$out/bin/wemeetapp" "$out/bin/wemeetapp-force-x11" \
      --set XDG_SESSION_TYPE x11 \
      --set QT_QPA_PLATFORM xcb \
      --unset WAYLAND_DISPLAY

    mkdir -p "$out/share/applications"
    install "${desktopItem}/share/applications/"*         "$out/share/applications/"

    mkdir -p "$out/share"
    if [ -d opt/wemeet/icons ]; then
      cp -r opt/wemeet/icons "$out/share"
    else
      echo "directory 'opt/wemeet/icons' not found"
    fi
  '';

  meta = with lib; {
    description = "Tencent Video Conferencing, tencent meeting ";
    homepage = " https://meeting.tencent.com/ ";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfree;
  };
}
