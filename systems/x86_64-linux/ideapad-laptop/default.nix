{
  # Snowfall Lib provides a customized `lib` instance with access to your flake's library
  # as well as the libraries available from your flake's inputs.
  lib,
  # An instance of `pkgs` with your overlays and packages applied is also available.
  # You also have access to your flake's inputs.

  # Additional metadata is provided by Snowfall Lib. # The namespace used for your flake, defaulting to "internal" if not set.
  system, # The system architecture for this host (eg. `x86_64-linux`). # The Snowfall Lib target for this system (eg. `x86_64-iso`). # A normalized name for the system target (eg. `iso`). # A boolean to determine whether this system is a virtual target using nixos-generators. # An attribute map of your defined hosts.

  # All other arguments come from the system system.
  ...
}:
let
  inherit (lib.khanelinix) enabled;
in
{
  imports = [
    ./disks.nix
  ];

  gregoryka-nixos-config = {
    nix = enabled;
  };

  system.stateVersion = "24.11"; # Did you read the comment?
}
