{
  description = "a pattern called polevault";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    pattern.url = "github:sotormd/pattern";
  };

  outputs =
    inputs:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs { inherit system; };
    in
    {
      nixosConfigurations.polevault = inputs.nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs;
        };
        modules = [ ./modules ];
      };
      packages.${system}.browser = pkgs.callPackage ./browser { };
    };
}
