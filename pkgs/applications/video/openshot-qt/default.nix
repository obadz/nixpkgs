{ stdenv, fetchurl, fetchFromGitHub, callPackage, makeWrapper, doxygen
, ffmpeg, python3Packages, qt55, gnome3, wrapGAppsHook 
}:

with stdenv.lib;

let
  libopenshot = callPackage ./libopenshot.nix {};
in
stdenv.mkDerivation rec {
  name = "openshot-qt-${version}";
  version = "2.0.7";

  src = fetchFromGitHub {
    owner = "OpenShot";
    repo = "openshot-qt";
    rev = "v${version}";
    sha256 = "1s4b61fd8cyjy8kvc25mqd97dkxx6gqmz02i42rrcriz51pw8wgh";
  };

  buildInputs = [ doxygen python3Packages.python makeWrapper ffmpeg gnome3.adwaita-icon-theme wrapGAppsHook ];

  propagatedBuildInputs = [
    qt55.qtbase
    qt55.qtmultimedia
    libopenshot
  ];

  installPhase = ''
    pout="$(toPythonPath $out)"
    mkdir -p "$pout"
    cp -r src/* "$pout"
    mkdir -p $out/bin
    makeWrapper "${python3Packages.python.interpreter} \"$pout/launch.py\"" $out/bin/openshot-qt \
      --prefix PYTHONPATH : "$pout" \
      --prefix PYTHONPATH : "$(toPythonPath ${libopenshot})" \
      --prefix PYTHONPATH : "$(toPythonPath ${python3Packages.pyqt5})" \
      --prefix PYTHONPATH : "$(toPythonPath ${python3Packages.sip_4_16})" \
      --prefix PYTHONPATH : "$(toPythonPath ${python3Packages.httplib2})"
  '';

  doCheck = false;

  meta = {
    homepage = "http://openshot.org/";
    description = "Free, open-source video editor";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.tohl ];
    platforms = platforms.linux;
  };
}
