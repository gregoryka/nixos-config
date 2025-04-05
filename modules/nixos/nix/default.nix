{
  config,
  lib,
  namespace,
  ...
}:
let
  inherit (lib) mkDefault mkIf;
  cfg = config.${namespace}.nix;
in
{
  imports = [ (lib.snowfall.fs.get-file "modules/shared/nix/default.nix") ];

  config = mkIf cfg.enable {
    documentation = {
      man.generateCaches = mkDefault true;

      nixos = {
        enable = true;

        options = {
          warningsAreErrors = true;
          splitBuild = true;
        };
      };
    };
    nix = {
      # Optimize nix for responsiveness
      daemonCPUSchedPolicy = "batch";
      daemonIOSchedClass = "idle";
      # Not used when idle is set as class, but for completion's sake
      daemonIOSchedPriority = 7;

      gc = {
        dates = "Mon *-*-* 01:00";
      };

      optimise = {
        automatic = true;
      };

    };
  };
}
