{ inputs }:
_final: _prev:
let
  gregnixLib = import ./default.nix { inherit inputs; };
in
{
  # Expose gregnix module functions directly
  gregnix = gregnixLib.flake.lib.module;

  # Expose all gregnix lib namespaces
  inherit (gregnixLib.flake.lib)
    file
    system
    theme
    base64
    ;

  inherit (gregnixLib.flake.lib.file)
    getFile
    getNixFiles
    importFiles
    importDir
    importDirPlain
    importSubdirs
    importModulesRecursive
    mergeAttrs
    ;

  inherit (gregnixLib.flake.lib.module)
    mkOpt
    mkOpt'
    mkBoolOpt
    mkBoolOpt'
    enabled
    disabled
    capitalize
    boolToNum
    default-attrs
    force-attrs
    nested-default-attrs
    nested-force-attrs
    decode
    ;

  # Add home-manager lib functions
  inherit (inputs.home-manager.lib) hm;
}
