{
  config,
  lib,
  pkgs,

  osConfig ? { },
  ...
}:
let
  inherit (lib) mkIf mkDefault;
  inherit (lib.gregnix) enabled;

  cfg = config.gregnix.suites.common;
in
{
  options.gregnix.suites.common = {
    enable = lib.mkEnableOption "common configuration";
  };

  config = mkIf cfg.enable {
    gregnix = {
      programs = {
        terminal = {

          tools = {
            atuin = mkDefault enabled;
            bat = mkDefault enabled;
            btop = mkDefault enabled;
            direnv = mkDefault enabled;
            eza = mkDefault enabled;
            fzf = mkDefault enabled;
            git = mkDefault enabled;
          };
        };
      };
    };
  };
}
