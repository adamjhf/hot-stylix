{ inputs, self, ... }:
let
  modulesDir = ../modules;
  appModules =
    builtins.map
      (name: modulesDir + "/${name}/hm.nix")
      (
        builtins.attrNames (
          builtins.filterAttrs (
            name: type: type == "directory" && builtins.pathExists (modulesDir + "/${name}/hm.nix")
          ) (builtins.readDir modulesDir)
        )
      );
in
{
  homeManagerModules = {
    default = self.homeManagerModules.hot-stylix;
    hot-stylix = { ... }: {
      _module.args.hotStylixInputs = inputs;
      imports = [
        inputs.stylix.homeModules.stylix
        ./hm.nix
      ] ++ appModules;
    };
  };
}
