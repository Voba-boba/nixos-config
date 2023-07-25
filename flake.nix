{
  description = "NixOS configuration flake";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }@inputs: 
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;

      #config = {
      #  allowUnfree = true;
      #};
    };
  in
  {
    nixosConfigurations = {
      cone = nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };

        modules = [ ./nixos/configuration.nix ];
      };
    };
  };
}
