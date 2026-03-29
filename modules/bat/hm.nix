{
  config,
  lib,
  hotStylixInputs,
  ...
}:
let
  cfg = config.programs.hot-stylix;
  runtimePath = "${cfg.stateDir}/bat/hot-stylix-current.tmTheme";
  templatePath = "${hotStylixInputs.stylix.outPath}/modules/bat/base16-stylix.tmTheme.mustache";
in
{
  options.programs.hot-stylix.targets.bat.enable = lib.mkEnableOption "runtime-managed bat theme" // {
    default = true;
  };

  config = lib.mkMerge [
    {
      hotStylix.supportedTargets.bat = {
        enable = config.programs.hot-stylix.targets.bat.enable;
        inherit runtimePath;

        shellFunctions = ''
          render_bat() {
            local scheme_file=$1
            local out_file=$2
            local base00="" base01="" base02="" base03="" base04="" base05="" base06="" base07=""
            local base08="" base09="" base0A="" base0B="" base0C="" base0D="" base0E="" base0F=""

            eval "$(emit_color_vars "$scheme_file")"

            sed \
              -e "s/{{base00-hex}}/$base00/g" \
              -e "s/{{base01-hex}}/$base01/g" \
              -e "s/{{base02-hex}}/$base02/g" \
              -e "s/{{base03-hex}}/$base03/g" \
              -e "s/{{base04-hex}}/$base04/g" \
              -e "s/{{base05-hex}}/$base05/g" \
              -e "s/{{base06-hex}}/$base06/g" \
              -e "s/{{base07-hex}}/$base07/g" \
              -e "s/{{base08-hex}}/$base08/g" \
              -e "s/{{base09-hex}}/$base09/g" \
              -e "s/{{base0A-hex}}/$base0A/g" \
              -e "s/{{base0B-hex}}/$base0B/g" \
              -e "s/{{base0C-hex}}/$base0C/g" \
              -e "s/{{base0D-hex}}/$base0D/g" \
              -e "s/{{base0E-hex}}/$base0E/g" \
              -e "s/{{base0F-hex}}/$base0F/g" \
              ${lib.escapeShellArg templatePath} > "$out_file"
          }
        '';

        render = ''
          render_bat "$scheme_file" "$tmp_path"
        '';

        reload = ''
          true
        '';
      };
    }
    (lib.mkIf config.programs.hot-stylix.targets.bat.enable {
      programs.bat.enable = lib.mkDefault true;
      programs.bat.config.theme = lib.mkForce "hot-stylix-current";

      xdg.configFile."bat/themes/hot-stylix-current.tmTheme".source =
        config.lib.file.mkOutOfStoreSymlink runtimePath;
    })
  ];
}
