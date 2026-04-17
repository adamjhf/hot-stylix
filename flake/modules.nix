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
  hotStylixModule = { ... }: {
    _module.args.hotStylixInputs = inputs;
    imports = [ ./hm.nix ] ++ appModules;
  };
in
{
  homeModules = {
    default = self.homeModules.hot-stylix;
    hot-stylix = hotStylixModule;
  };
}
