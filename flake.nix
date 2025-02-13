{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    snowfall-lib = {
      url = "github:snowfallorg/lib";
      inputs.nixpkgs.follows = "nixpkgs";
    };


  };

  outputs = inputs: 
    inputs.snowfall-lib.mkFlake {
      inherit inputs;
      
      src = ./.;
      snowfall = {
        namespace = "gregoryka-nixos-config";
        meta = {
          title = "Gregory's Nixos Config";
        };
      };
  };
}
