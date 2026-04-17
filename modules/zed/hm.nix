{
  config,
  lib,
  hotStylixInputs,
  ...
}:
let
  cfg = config.programs.hot-stylix;
  runtimePath = "${cfg.stateDir}/zed/themes/hot-stylix-current.json";
  templatePath = "${hotStylixInputs.stylix.inputs."tinted-zed".outPath}/templates/default.mustache";
in
{
  options.programs.hot-stylix.targets.zed.enable = lib.mkEnableOption "runtime-managed zed theme" // {
    default = config.programs.zed-editor.enable;
  };

  config = lib.mkMerge [
    {
      hotStylix.supportedTargets.zed = {
        enable = config.programs.hot-stylix.targets.zed.enable;
        inherit runtimePath;

        shellFunctions = ''
          render_zed() {
            local scheme_file=$1
            local out_file=$2
            local base00="" base01="" base02="" base03="" base04="" base05="" base06="" base07=""
            local base08="" base09="" base0A="" base0B="" base0C="" base0D="" base0E="" base0F=""
            local base00_hex="" base01_hex="" base02_hex="" base03_hex="" base04_hex="" base05_hex="" base06_hex="" base07_hex=""
            local base08_hex="" base09_hex="" base0A_hex="" base0B_hex="" base0C_hex="" base0D_hex="" base0E_hex="" base0F_hex=""

            eval "$(emit_color_vars "$scheme_file")"
            base00_hex="''${base00#\#}"
            base01_hex="''${base01#\#}"
            base02_hex="''${base02#\#}"
            base03_hex="''${base03#\#}"
            base04_hex="''${base04#\#}"
            base05_hex="''${base05#\#}"
            base06_hex="''${base06#\#}"
            base07_hex="''${base07#\#}"
            base08_hex="''${base08#\#}"
            base09_hex="''${base09#\#}"
            base0A_hex="''${base0A#\#}"
            base0B_hex="''${base0B#\#}"
            base0C_hex="''${base0C#\#}"
            base0D_hex="''${base0D#\#}"
            base0E_hex="''${base0E#\#}"
            base0F_hex="''${base0F#\#}"

            sed \
              -e "s/{{scheme-name}}/hot-stylix-current/g" \
              -e "s/{{scheme-author}}/hot-stylix/g" \
              -e "s/{{base00-hex}}/$base00_hex/g" \
              -e "s/{{base01-hex}}/$base01_hex/g" \
              -e "s/{{base02-hex}}/$base02_hex/g" \
              -e "s/{{base03-hex}}/$base03_hex/g" \
              -e "s/{{base04-hex}}/$base04_hex/g" \
              -e "s/{{base05-hex}}/$base05_hex/g" \
              -e "s/{{base06-hex}}/$base06_hex/g" \
              -e "s/{{base07-hex}}/$base07_hex/g" \
              -e "s/{{base08-hex}}/$base08_hex/g" \
              -e "s/{{base09-hex}}/$base09_hex/g" \
              -e "s/{{base0A-hex}}/$base0A_hex/g" \
              -e "s/{{base0B-hex}}/$base0B_hex/g" \
              -e "s/{{base0C-hex}}/$base0C_hex/g" \
              -e "s/{{base0D-hex}}/$base0D_hex/g" \
              -e "s/{{base0E-hex}}/$base0E_hex/g" \
              -e "s/{{base0F-hex}}/$base0F_hex/g" \
              ${lib.escapeShellArg templatePath} > "$out_file"
          }
        '';

        render = ''
          render_zed "$scheme_file" "$tmp_path"
        '';

        reload = ''
          true
        '';
      };
    }
    (lib.mkIf config.programs.hot-stylix.targets.zed.enable {
      programs.zed-editor.package = lib.mkDefault null;
      programs.zed-editor.userSettings.theme = lib.mkForce "Base16 hot-stylix-current";
      programs.zed-editor.themes.hot-stylix-current = config.lib.file.mkOutOfStoreSymlink runtimePath;
    })
  ];
}
