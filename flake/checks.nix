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
        inputs.stylix.homeModules.stylix
        self.homeModules.default
        ({
          config,
          ...
        }: {
          home.username = "tester";
          home.homeDirectory =
            if pkgs.stdenv.hostPlatform.isDarwin then "/Users/tester" else "/home/tester";
          home.stateVersion = "25.05";

          programs.hot-stylix.enable = true;
          programs.hot-stylix.schemes.espresso = ''
            scheme: "Espresso"
            author: "Check"
            base00: "2d2d2d"
            base01: "393939"
            base02: "515151"
            base03: "777777"
            base04: "b4b7b4"
            base05: "cccccc"
            base06: "e0e0e0"
            base07: "ffffff"
            base08: "f2777a"
            base09: "f99157"
            base0A: "ffcc66"
            base0B: "99cc99"
            base0C: "66cccc"
            base0D: "6699cc"
            base0E: "cc99cc"
            base0F: "d27b53"
          '';
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
          programs.zed-editor.enable = true;
          programs.zed-editor.package = null;
          programs.zed-editor.userSettings.telemetry.metrics = false;

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
