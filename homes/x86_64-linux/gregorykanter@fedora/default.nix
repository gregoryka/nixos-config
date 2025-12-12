{
  config,
  lib,
  pkgs,

  ...
}:
let
  inherit (lib.gregnix) enabled;
in
{
  gregnix = {
    user = {
      enable = true;
      name = "gregorykanter";
    };

    suites = {
      common = enabled;
    };
  };


  home.stateVersion = "25.11";
}
