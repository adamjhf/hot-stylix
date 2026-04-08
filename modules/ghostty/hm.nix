{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.hot-stylix;
  runtimePath = "${cfg.stateDir}/ghostty/current-config";
  keyValueSettings = {
    listsAsDuplicateKeys = true;
    mkKeyValue = lib.generators.mkKeyValueDefault { } " = ";
  };
  keyValue = pkgs.formats.keyValue keyValueSettings;
  ghosttySettings = config.programs.ghostty.settings;
  rawConfigFiles = ghosttySettings."config-file" or null;
  configFiles =
    if rawConfigFiles == null then
      [ ]
    else if builtins.isList rawConfigFiles then
      rawConfigFiles
    else
      [ rawConfigFiles ];
  cleanedConfigFiles = lib.filter (entry: entry != "?temp") configFiles;
  baseSettings = builtins.removeAttrs ghosttySettings [ "config-file" ];
  baseSettingsFile =
    if baseSettings == { } then null else keyValue.generate "hot-stylix-ghostty-base-config" baseSettings;
  renderConfigSource = pkgs.runCommand "hot-stylix-ghostty-config" { } (
    lib.optionalString (baseSettingsFile != null) ''
      cat ${baseSettingsFile} > "$out"
    ''
    + lib.optionalString (baseSettingsFile == null) ''
      : > "$out"
    ''
    + lib.concatMapStrings (
      entry: ''
        printf '%s\n' ${lib.escapeShellArg "config-file = ${entry}"} >> "$out"
      ''
    ) (cleanedConfigFiles ++ [ runtimePath ])
  );
in
{
  options.programs.hot-stylix.targets.ghostty.enable = lib.mkEnableOption "runtime-managed Ghostty theme" // {
    default = config.programs.ghostty.enable || ghosttySettings != { } || config.programs.ghostty.themes != { };
  };

  config = lib.mkMerge [
    {
      hotStylix.supportedTargets.ghostty = {
        enable = config.programs.hot-stylix.targets.ghostty.enable;
        inherit runtimePath;

        shellFunctions = ''
          render_ghostty() {
            local scheme_file=$1
            local out_file=$2
            local base00="" base01="" base02="" base03="" base04="" base05="" base06="" base07=""
            local base08="" base09="" base0A="" base0B="" base0C="" base0D="" base0E="" base0F=""

            eval "$(emit_color_vars "$scheme_file")"

            cat > "$out_file" <<EOF
background = $base00
foreground = $base05
cursor-color = $base05
selection-background = $base02
selection-foreground = $base05
palette = 0=$base00
palette = 1=$base08
palette = 2=$base0B
palette = 3=$base0A
palette = 4=$base0D
palette = 5=$base0E
palette = 6=$base0C
palette = 7=$base05
palette = 8=$base03
palette = 9=$base08
palette = 10=$base0B
palette = 11=$base0A
palette = 12=$base0D
palette = 13=$base0E
palette = 14=$base0C
palette = 15=$base07
palette = 16=$base09
palette = 17=$base0F
palette = 18=$base01
palette = 19=$base02
palette = 20=$base04
palette = 21=$base06
macos-icon-ghost-color = $base07
macos-icon-screen-color = $base0D
EOF
          }

          reload_ghostty() {
            local ghostty_pids=""

            ghostty_pids="$(pgrep -x ghostty || true)"
            [ -n "$ghostty_pids" ] || return 0

            printf '%s\n' "$ghostty_pids" | xargs -n1 kill -USR2 >/dev/null 2>&1 || true
            [ "$(uname -s)" = "Darwin" ] || return 0

            timeout 2s osascript >/dev/null 2>&1 <<'EOF' || true
tell application id "com.mitchellh.ghostty"
  repeat with target_terminal in terminals
    perform action "reload_config" on target_terminal
  end repeat
end tell
EOF
          }
        '';

        render = ''
          render_ghostty "$scheme_file" "$tmp_path"
        '';

        reload = ''
          reload_ghostty
        '';
      };
    }
    (lib.mkIf config.programs.hot-stylix.targets.ghostty.enable {
      programs.ghostty.package = lib.mkDefault null;

      xdg.configFile = lib.mkMerge [
        {
          "ghostty/config".source = lib.mkForce renderConfigSource;
        }
        (lib.mkIf (config.programs.ghostty.themes != { }) (
          lib.mapAttrs' (name: value: {
            name = "ghostty/themes/${name}";
            value = lib.mkForce {
              source = keyValue.generate "ghostty-${name}-theme" value;
            };
          }) config.programs.ghostty.themes
        ))
      ];
    })
  ];
}
