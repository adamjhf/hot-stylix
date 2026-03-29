{
  config,
  lib,
  hotStylixInputs,
  ...
}:
let
  cfg = config.programs.hot-stylix;
  runtimePath = "${cfg.stateDir}/helix/hot-stylix-current.toml";
  templatePath = "${hotStylixInputs.stylix.inputs."base16-helix".outPath}/templates/default.mustache";
  transparent = config.stylix.opacity.terminal != 1.0;
in
{
  options.programs.hot-stylix.targets.helix.enable = lib.mkEnableOption "runtime-managed helix theme" // {
    default = true;
  };

  config = lib.mkMerge [
    {
      hotStylix.supportedTargets.helix = {
        enable = config.programs.hot-stylix.targets.helix.enable;
        inherit runtimePath;

        shellFunctions = ''
          render_helix() {
            local scheme_file=$1
            local out_file=$2
            local transparent=$3
            local base00="" base01="" base02="" base03="" base04="" base05="" base06="" base07=""
            local base08="" base09="" base0A="" base0B="" base0C="" base0D="" base0E="" base0F=""

            eval "$(emit_color_vars "$scheme_file")"

            sed \
              -e "s/{{scheme-name}}/hot-stylix-current/g" \
              -e "s/{{scheme-author}}/hot-stylix/g" \
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

            if [ "$transparent" = 1 ]; then
              sed 's/, bg = "base00"//g' "$out_file" > "$out_file.tmp"
              mv "$out_file.tmp" "$out_file"
            fi
          }
        '';

        render = ''
          render_helix "$scheme_file" "$tmp_path" ${if transparent then "1" else "0"}
        '';

        reload = ''
          true
        '';
      };
    }
    (lib.mkIf config.programs.hot-stylix.targets.helix.enable {
      programs.helix.enable = lib.mkDefault true;
      programs.helix.settings.theme = lib.mkForce "hot-stylix-current";

      xdg.configFile."helix/themes/hot-stylix-current.toml".source =
        config.lib.file.mkOutOfStoreSymlink runtimePath;
    })
  ];
}
