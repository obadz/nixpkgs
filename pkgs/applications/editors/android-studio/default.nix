{ stdenv, callPackage, makeFontsConf, gnome2 }:

let
  mkStudio = opts: callPackage (import ./common.nix opts) {
    fontsConf = makeFontsConf {
      fontDirectories = [];
    };
    inherit (gnome2) GConf gnome_vfs;
  };
  stableVersion = {
    version = "3.2.1.0"; # "Android Studio 3.2.1"
    build = "181.5056338";
    sha256Hash = "117skqjax1xz9plarhdnrw2rwprjpybdc7mx7wggxapyy920vv5r";
  };
  betaVersion = {
    version = "3.3.0.19"; # "Android Studio 3.3 RC 3"
    build = "182.5183351";
    sha256Hash = "1rql4kxjic4qjcd8zssw2mmi55cxpzd0wp5g0kzwk5wybsfdcqhy";
  };
  latestVersion = { # canary & dev
    version = "3.4.0.8"; # "Android Studio 3.4 Canary 9"
    build = "183.5186062";
    sha256Hash = "04i7ys0qzj3039h41q4na6737gl55wpp6hiwfas2h6zwvj25a9z9";
  };
in rec {
  # Old alias
  preview = beta;

  # Attributes are named by their corresponding release channels

  stable = mkStudio (stableVersion // {
    channel = "stable";
    pname = "android-studio";
  });

  beta = mkStudio (betaVersion // {
    channel = "beta";
    pname = "android-studio-preview";
  });

  dev = mkStudio (latestVersion // {
    channel = "dev";
    pname = "android-studio-dev";
  });

  canary = mkStudio (latestVersion // {
    channel = "canary";
    pname = "android-studio-canary";
  });
}
