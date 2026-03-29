{ inputs, self, nixpkgs }:
let
  systems = [
    "aarch64-darwin"
    "x86_64-linux"
  ];
  forAllSystems = nixpkgs.lib.genAttrs systems;
in
forAllSystems (
  system:
  let
    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    home = inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [
        self.homeManagerModules.default
        {
          home.username = "tester";
          home.homeDirectory =
            if pkgs.stdenv.hostPlatform.isDarwin then "/Users/tester" else "/home/tester";
          home.stateVersion = "25.05";

          programs.hot-stylix.enable = true;
          programs.ghostty.package = null;
          programs.ghostty.systemd.enable = false;

          stylix.enable = true;
          stylix.base16Scheme = pkgs.base16-schemes + "/share/themes/tokyo-night-dark.yaml";
        }
      ];
    };
  in
  {
    default = home.activationPackage;
  }
)
