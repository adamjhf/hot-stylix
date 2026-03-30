{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.hot-stylix;
  runtimePath = "${cfg.stateDir}/lazygit/config.yml";
  yamlFormat = pkgs.formats.yaml { };
  configDir =
    if pkgs.stdenv.hostPlatform.isDarwin && !config.xdg.enable then
      "Library/Application Support"
    else
      config.xdg.configHome;
  baseSettings =
    let
      settings = config.programs.lazygit.settings;
      gui = settings.gui or null;
      guiWithoutTheme =
        if gui == null then
          null
        else
          builtins.removeAttrs gui [ "theme" ];
      stripped =
        if gui == null then
          settings
        else if guiWithoutTheme == { } then
          builtins.removeAttrs settings [ "gui" ]
        else
          settings // { gui = guiWithoutTheme; };
    in
    yamlFormat.generate "hot-stylix-lazygit-base.yml" stripped;
in
{
  options.programs.hot-stylix.targets.lazygit.enable = lib.mkEnableOption "runtime-managed lazygit theme" // {
    default = true;
  };

  config = lib.mkMerge [
    {
      hotStylix.supportedTargets.lazygit = {
        enable = config.programs.hot-stylix.targets.lazygit.enable;
        inherit runtimePath;

        shellFunctions = ''
          render_lazygit() {
            local out_file=$1
            local base00="" base01="" base02="" base03="" base04="" base05="" base06="" base07=""
            local base08="" base09="" base0A="" base0B="" base0C="" base0D="" base0E="" base0F=""
            local base_json="" merged_json=""

            eval "$(emit_color_vars "$scheme_file")"
            base_json="$(yj -yj < ${lib.escapeShellArg baseSettings})"
            merged_json="$(
              jq -n \
                --argjson base "$base_json" \
                --arg base02 "$base02" \
                --arg base03 "$base03" \
                --arg base04 "$base04" \
                --arg base05 "$base05" \
                --arg base06 "$base06" \
                --arg base08 "$base08" \
                --arg base0D "$base0D" \
                '$base * {
                  gui: (
                    ($base.gui // {}) * {
                      theme: {
                        activeBorderColor: [$base0D, "bold"],
                        inactiveBorderColor: [$base03],
                        searchingActiveBorderColor: [$base04, "bold"],
                        optionsTextColor: [$base06],
                        selectedLineBgColor: [$base03],
                        cherryPickedCommitBgColor: [$base02],
                        cherryPickedCommitFgColor: [$base03],
                        unstagedChangesColor: [$base08],
                        defaultFgColor: [$base05]
                      }
                    }
                  )
                }'
            )"

            printf '%s\n' "$merged_json" | yj -jy > "$out_file"
          }
        '';

        render = ''
          render_lazygit "$tmp_path"
        '';

        reload = ''
          true
        '';
      };
    }
    (lib.mkIf config.programs.hot-stylix.targets.lazygit.enable {
      programs.lazygit.enable = lib.mkDefault true;

      home.file."${configDir}/lazygit/config.yml" = lib.mkForce {
        source = config.lib.file.mkOutOfStoreSymlink runtimePath;
      };
    })
  ];
}
