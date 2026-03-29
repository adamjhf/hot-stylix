{
  description = "Hot Stylix target switching for Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      moduleOutputs = import ./flake/modules.nix { inherit inputs self; };
      checks = import ./flake/checks.nix { inherit inputs self nixpkgs; };
    in
    moduleOutputs // {
      inherit checks;
    };
}
