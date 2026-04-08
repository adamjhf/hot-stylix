{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.hot-stylix;
  starshipCfg = config.programs.starship;
  runtimePath = "${cfg.stateDir}/starship/starship.toml";
  configPath = starshipCfg.configPath;
  tomlFormat = pkgs.formats.toml { };
  settingsFile = tomlFormat.generate "hot-stylix-starship-base-settings.toml" starshipCfg.settings;
  baseConfigPath =
    if starshipCfg.presets == [ ] then
      settingsFile
    else
      pkgs.runCommand "hot-stylix-starship-base.toml"
        {
          nativeBuildInputs = [ pkgs.yq ];
        }
        ''
          tomlq -s -t 'reduce .[] as $item ({}; . * $item)' \
            ${
              lib.concatStringsSep
                " "
                (map (preset: "${starshipCfg.package}/share/starship/presets/${preset}.toml") starshipCfg.presets)
            } \
            ${settingsFile} \
            > "$out"
        '';
in
{
  options.programs.hot-stylix.targets.starship.enable = lib.mkEnableOption "runtime-managed starship theme" // {
    default = config.programs.starship.enable;
  };

  config = lib.mkMerge [
    {
      hotStylix.supportedTargets.starship = {
        enable = config.programs.hot-stylix.targets.starship.enable;
        inherit runtimePath;

        shellFunctions = ''
          render_starship() {
            local out_file=$1
            local base00="" base01="" base02="" base03="" base04="" base05="" base06="" base07=""
            local base08="" base09="" base0A="" base0B="" base0C="" base0D="" base0E="" base0F=""
            local base10="" base11="" base12="" base13="" base14="" base15="" base16="" base17=""
            local base_json="" merged_json=""

            eval "$(emit_color_vars "$scheme_file")"
            base_json="$(yj -tj < ${lib.escapeShellArg baseConfigPath})"
            merged_json="$(
              jq -n \
                --argjson base "$base_json" \
                --arg base00 "$base00" \
                --arg base01 "$base01" \
                --arg base02 "$base02" \
                --arg base03 "$base03" \
                --arg base04 "$base04" \
                --arg base05 "$base05" \
                --arg base06 "$base06" \
                --arg base07 "$base07" \
                --arg base08 "$base08" \
                --arg base09 "$base09" \
                --arg base0A "$base0A" \
                --arg base0B "$base0B" \
                --arg base0C "$base0C" \
                --arg base0D "$base0D" \
                --arg base0E "$base0E" \
                --arg base0F "$base0F" \
                --arg base10 "$base10" \
                --arg base11 "$base11" \
                --arg base12 "$base12" \
                --arg base13 "$base13" \
                --arg base14 "$base14" \
                --arg base15 "$base15" \
                --arg base16 "$base16" \
                --arg base17 "$base17" \
                --arg defaultBase00 "#${config.lib.stylix.colors.base00}" \
                --arg defaultBase01 "#${config.lib.stylix.colors.base01}" \
                --arg defaultBase02 "#${config.lib.stylix.colors.base02}" \
                --arg defaultBase03 "#${config.lib.stylix.colors.base03}" \
                --arg defaultBase04 "#${config.lib.stylix.colors.base04}" \
                --arg defaultBase05 "#${config.lib.stylix.colors.base05}" \
                --arg defaultBase06 "#${config.lib.stylix.colors.base06}" \
                --arg defaultBase07 "#${config.lib.stylix.colors.base07}" \
                --arg defaultBase08 "#${config.lib.stylix.colors.base08}" \
                --arg defaultBase09 "#${config.lib.stylix.colors.base09}" \
                --arg defaultBase0A "#${config.lib.stylix.colors.base0A}" \
                --arg defaultBase0B "#${config.lib.stylix.colors.base0B}" \
                --arg defaultBase0C "#${config.lib.stylix.colors.base0C}" \
                --arg defaultBase0D "#${config.lib.stylix.colors.base0D}" \
                --arg defaultBase0E "#${config.lib.stylix.colors.base0E}" \
                --arg defaultBase0F "#${config.lib.stylix.colors.base0F}" \
                --arg defaultBase10 "#${config.lib.stylix.colors.base00}" \
                --arg defaultBase11 "#${config.lib.stylix.colors.base00}" \
                --arg defaultBase12 "#${config.lib.stylix.colors.base08}" \
                --arg defaultBase13 "#${config.lib.stylix.colors.base0A}" \
                --arg defaultBase14 "#${config.lib.stylix.colors.base0B}" \
                --arg defaultBase15 "#${config.lib.stylix.colors.base0C}" \
                --arg defaultBase16 "#${config.lib.stylix.colors.base0D}" \
                --arg defaultBase17 "#${config.lib.stylix.colors.base0E}" \
                '
                  def remap:
                    if . == $defaultBase00 then $base00
                    elif . == $defaultBase01 then $base01
                    elif . == $defaultBase02 then $base02
                    elif . == $defaultBase03 then $base03
                    elif . == $defaultBase04 then $base04
                    elif . == $defaultBase05 then $base05
                    elif . == $defaultBase06 then $base06
                    elif . == $defaultBase07 then $base07
                    elif . == $defaultBase08 then $base08
                    elif . == $defaultBase09 then $base09
                    elif . == $defaultBase0A then $base0A
                    elif . == $defaultBase0B then $base0B
                    elif . == $defaultBase0C then $base0C
                    elif . == $defaultBase0D then $base0D
                    elif . == $defaultBase0E then $base0E
                    elif . == $defaultBase0F then $base0F
                    elif . == $defaultBase10 then $base10
                    elif . == $defaultBase11 then $base11
                    elif . == $defaultBase12 then $base12
                    elif . == $defaultBase13 then $base13
                    elif . == $defaultBase14 then $base14
                    elif . == $defaultBase15 then $base15
                    elif . == $defaultBase16 then $base16
                    elif . == $defaultBase17 then $base17
                    else .
                    end;

                  $base * {
                  palette: "base16",
                  palettes: (
                    ($base.palettes // {}) * {
                      base16: (
                        (($base.palettes.base16 // {}) | with_entries(.value |= remap)) * {
                          black: $base00,
                          "bright-black": $base03,
                          white: $base05,
                          "bright-white": $base07,
                          purple: $base0E,
                          "bright-purple": $base17,
                          red: $base08,
                          orange: $base09,
                          yellow: $base0A,
                          green: $base0B,
                          cyan: $base0C,
                          blue: $base0D,
                          magenta: $base0E,
                          brown: $base0F,
                          "bright-red": $base12,
                          "bright-yellow": $base13,
                          "bright-green": $base14,
                          "bright-cyan": $base15,
                          "bright-blue": $base16,
                          "bright-magenta": $base17,
                          base00: $base00,
                          base01: $base01,
                          base02: $base02,
                          base03: $base03,
                          base04: $base04,
                          base05: $base05,
                          base06: $base06,
                          base07: $base07,
                          base08: $base08,
                          base09: $base09,
                          base0A: $base0A,
                          base0B: $base0B,
                          base0C: $base0C,
                          base0D: $base0D,
                          base0E: $base0E,
                          base0F: $base0F,
                          base10: $base10,
                          base11: $base11,
                          base12: $base12,
                          base13: $base13,
                          base14: $base14,
                          base15: $base15,
                          base16: $base16,
                          base17: $base17
                        }
                      )
                    }
                  )
                }'
            )"

            printf '%s\n' "$merged_json" | yj -jt > "$out_file"
          }
        '';

        render = ''
          render_starship "$tmp_path"
        '';

        reload = ''
          true
        '';
      };
    }
    (lib.mkIf config.programs.hot-stylix.targets.starship.enable {
      home.file."${configPath}".source = lib.mkForce (
        config.lib.file.mkOutOfStoreSymlink runtimePath
      );
    })
  ];
}
