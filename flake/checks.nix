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
        ({
          config,
          ...
        }: {
          home.username = "tester";
          home.homeDirectory =
            if pkgs.stdenv.hostPlatform.isDarwin then "/Users/tester" else "/home/tester";
          home.stateVersion = "25.05";

          programs.hot-stylix.enable = true;
          programs.ghostty.package = null;
          programs.ghostty.systemd.enable = false;
          programs.starship.enable = true;
          programs.starship.presets = [ "nerd-font-symbols" ];
          programs.starship.settings = {
            add_newline = false;
            format = "$directory$character";
            palettes.base16 = {
              background = "#${config.lib.stylix.colors.base02}";
              directory = "#${config.lib.stylix.colors.base0B}";
              git_branch = "#${config.lib.stylix.colors.base08}";
              prompt_ok = "#${config.lib.stylix.colors.base0B}";
            };
          };

          stylix.enable = true;
          stylix.base16Scheme = "${inputs.stylix.inputs."tinted-schemes"}/base16/tokyo-night-dark.yaml";
        })
      ];
    };
  in
  {
    default = home.activationPackage;
  }
)
