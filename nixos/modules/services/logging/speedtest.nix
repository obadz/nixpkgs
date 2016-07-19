{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.speedtest;
in {
  options.services.speedtest = {
    enable = mkEnableOption ''
      Enable the speedtest service.
    '';

    server = mkOption {
      type = types.nullOr types.int;
      default = null;
      description = ''
        The identifier of the speedtest server you wish to use.
        See `speedtest --list`.
      '';
    };

    updateAt = mkOption {
      type = types.string;
      default = "5 min";
      example = "hourly";
      description = ''
        Specification of the time at which speedtest will get updated.
        (in the format described by <citerefentry>
          <refentrytitle>systemd.time</refentrytitle>
          <manvolnum>5</manvolnum></citerefentry>)
      '';
    };
  };

  config = mkIf cfg.enable {
    systemd.services.speedtest = mkIf cfg.enable {
      description = "speedtest log collector";
      serviceConfig = {
        Type  = "oneshot";
        User  = "nobody";
        Group = "nogroup";
        ExecStart = with builtins; pkgs.writeScript "speedtest.sh" ''
          #! ${pkgs.bash}/bin/bash
          ${pkgs.speedtest-cli}/bin/speedtest --simple ${lib.optionalString (isInt cfg.server) (" --server " + (toString cfg.server))} |
            xargs
        '';
      };
    };

    systemd.timers.speedtest = mkIf (cfg.updateAt != null) {
      description = "speedtest log collector";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnActiveSec        = cfg.updateAt;
        RandomizedDelaySec = 30; # +/- 30 seconds
      };
    };
  };
}
