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
    default = config.programs.bat.enable;
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

          reload_bat() {
            command -v bat >/dev/null 2>&1 || return 0
            (
              export XDG_CACHE_HOME="''${XDG_CACHE_HOME:-$HOME/.cache}"
              export XDG_CONFIG_HOME="''${XDG_CONFIG_HOME:-$HOME/.config}"
              tmpdir="$(mktemp -d)"
              cd "$tmpdir"
              bat cache --build >/dev/null 2>&1 || true
              rmdir "$tmpdir" >/dev/null 2>&1 || true
            )
          }
        '';

        render = ''
          render_bat "$scheme_file" "$tmp_path"
        '';

        reload = ''
          reload_bat
        '';
      };
    }
    (lib.mkIf config.programs.hot-stylix.targets.bat.enable {
      programs.bat.config.theme = lib.mkForce "hot-stylix-current";

      xdg.configFile."bat/themes/hot-stylix-current.tmTheme".source =
        config.lib.file.mkOutOfStoreSymlink runtimePath;
    })
  ];
}
