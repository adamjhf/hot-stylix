{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.programs.hot-stylix;

  yamlFormat = pkgs.formats.yaml { };

  stateDir = cfg.stateDir;
  currentStyleFile = "${stateDir}/current-style";
  schemeNamePattern = "^[A-Za-z0-9._+-]+$";
  builtinSchemeDir = "${pkgs.base16-schemes.src}/base16";

  availableSchemes =
    cfg.schemes
    // lib.optionalAttrs (!(cfg.schemes ? "${cfg.defaultStyle}")) {
      "${cfg.defaultStyle}" = config.stylix.base16Scheme;
    };

  schemeSource =
    name: scheme:
    if builtins.isPath scheme then
      scheme
    else if builtins.isString scheme && lib.hasPrefix "/" scheme && builtins.pathExists scheme then
      builtins.path {
        path = scheme;
        name = "hot-stylix-scheme-${name}.yaml";
      }
    else if builtins.isString scheme then
      pkgs.writeText "hot-stylix-scheme-${name}.yaml" scheme
    else
      yamlFormat.generate "hot-stylix-scheme-${name}.yaml" scheme;

  supportedTargets = config.hotStylix.supportedTargets;
  enabledTargets = lib.filterAttrs (_: target: target.enable) supportedTargets;
  enabledTargetNames = lib.attrNames enabledTargets;
  schemeNames = lib.attrNames availableSchemes;

  schemeSources = pkgs.runCommand "hot-stylix-scheme-sources" { } (
    ''
      mkdir -p "$out"
    ''
    + lib.concatMapStringsSep "\n" (
      schemeName:
      let
        sourcePath = schemeSource schemeName availableSchemes.${schemeName};
      in
      ''
        ln -s ${lib.escapeShellArg "${sourcePath}"} "$out/${schemeName}"
      ''
    ) schemeNames
  );

  shellList = lib.concatStringsSep " " (map lib.escapeShellArg enabledTargetNames);
  shellFunctions = lib.concatMapStringsSep "\n\n" (
    name: enabledTargets.${name}.shellFunctions
  ) enabledTargetNames;

  targetApplyCases = lib.concatMapStringsSep "\n" (
    name:
    let
      target = enabledTargets.${name};
    in
    ''
      ${name})
        target_path=${lib.escapeShellArg target.runtimePath}
        mkdir -p "$(dirname "$target_path")"
        tmp_path="$(mktemp "$target_path.XXXXXX")"
        ${target.render}
        mv "$tmp_path" "$target_path"
        ;;
    ''
  ) enabledTargetNames;

  targetReloadCases = lib.concatMapStringsSep "\n" (
    name:
    let
      target = enabledTargets.${name};
    in
    ''
      ${name})
        ${target.reload}
        ;;
    ''
  ) enabledTargetNames;

  cli = pkgs.writeShellApplication {
    name = cfg.commandName;
    runtimeInputs = with pkgs; [
      coreutils
      findutils
      jq
      yj
    ];
    text = ''
            set -euo pipefail
            export PATH="$PATH:/usr/bin:/bin:/usr/sbin:/sbin"

            state_dir=${lib.escapeShellArg stateDir}
            current_style_file=${lib.escapeShellArg currentStyleFile}
            scheme_dir=${lib.escapeShellArg schemeSources}
            builtin_scheme_dir=${lib.escapeShellArg builtinSchemeDir}
            default_style=${lib.escapeShellArg cfg.defaultStyle}

            usage() {
              cat <<'EOF'
      usage: ${cfg.commandName} <list|current|set|reset> [style]

      commands:
        list            list all available styles
        current         print the current style name
        set <style>     apply a style, persist it, reload supported apps
        reset           switch back to the Stylix default style
      EOF
            }

            ensure_state_dir() {
              mkdir -p "$state_dir"
            }

            current_style() {
              if [ -s "$current_style_file" ]; then
                cat "$current_style_file"
              else
                printf '%s\n' "$default_style"
              fi
            }

            scheme_file_for_style() {
              local style=$1

              if [ -f "$scheme_dir/$style" ]; then
                printf '%s\n' "$scheme_dir/$style"
              elif [ -f "$builtin_scheme_dir/$style.yaml" ]; then
                printf '%s\n' "$builtin_scheme_dir/$style.yaml"
              elif [ -f "$builtin_scheme_dir/$style.yml" ]; then
                printf '%s\n' "$builtin_scheme_dir/$style.yml"
              else
                return 1
              fi
            }

            emit_color_vars() {
              local scheme_file=$1

              yj -yj < "$scheme_file" | jq -r '
                . as $scheme
                | [
                  "base00",
                  "base01",
                  "base02",
                  "base03",
                  "base04",
                  "base05",
                  "base06",
                  "base07",
                  "base08",
                  "base09",
                  "base0A",
                  "base0B",
                  "base0C",
                  "base0D",
                  "base0E",
                  "base0F",
                  "base10",
                  "base11",
                  "base12",
                  "base13",
                  "base14",
                  "base15",
                  "base16",
                  "base17"
                ][]
                | . as $key
                | "\($key)=\(
                    (
                      $scheme.palette[$key]
                      // $scheme[$key]
                      // (
                        if $key == "base10" or $key == "base11" then
                          ($scheme.palette.base00 // $scheme.base00)
                        elif $key == "base12" then
                          ($scheme.palette.base08 // $scheme.base08)
                        elif $key == "base13" then
                          ($scheme.palette.base0A // $scheme.base0A)
                        elif $key == "base14" then
                          ($scheme.palette.base0B // $scheme.base0B)
                        elif $key == "base15" then
                          ($scheme.palette.base0C // $scheme.base0C)
                        elif $key == "base16" then
                          ($scheme.palette.base0D // $scheme.base0D)
                        elif $key == "base17" then
                          ($scheme.palette.base0E // $scheme.base0E)
                        else
                          empty
                        end
                      )
                      // error("missing " + $key)
                    ) | @sh
                  )"
              '
            }

            ${shellFunctions}

            reload_target() {
              case "$1" in
                ${targetReloadCases}
              esac
            }

            apply_style() {
              local style="''${1:-}"
              local scheme_file
              local targets=(${shellList})

              if [ -z "$style" ]; then
                printf 'missing style name\n' >&2
                usage >&2
                exit 1
              fi

              if ! scheme_file="$(scheme_file_for_style "$style")"; then
                printf 'unknown style: %s\n' "$style" >&2
                exit 1
              fi

              ensure_state_dir

              for target in "''${targets[@]}"; do
                case "$target" in
                  ${targetApplyCases}
                esac
              done

              printf '%s\n' "$style" > "$current_style_file"

              for target in "''${targets[@]}"; do
                reload_target "$target"
              done
            }

            command="''${1:-}"

            case "$command" in
              list)
                {
                  find "$builtin_scheme_dir" -mindepth 1 -maxdepth 1 -type f \( -name '*.yaml' -o -name '*.yml' \) -exec basename {} \;
                  find "$scheme_dir" -mindepth 1 -maxdepth 1 -type l -exec basename {} \;
                } | sed -e 's/\.yaml$//' -e 's/\.yml$//' | sort -u
                ;;
              current)
                current_style
                ;;
              set)
                shift || true
                apply_style "''${1:-}"
                ;;
              reset)
                apply_style "$default_style"
                ;;
              ""|-h|--help|help)
                usage
                ;;
              *)
                printf 'unknown command: %s\n' "$command" >&2
                usage >&2
                exit 1
                ;;
            esac
    '';
  };
in
{
  options.hotStylix.supportedTargets = lib.mkOption {
    internal = true;
    default = { };
    type = lib.types.attrsOf (
      lib.types.submodule {
        options = {
          enable = lib.mkOption {
            type = lib.types.bool;
          };
          runtimePath = lib.mkOption {
            type = lib.types.str;
          };
          shellFunctions = lib.mkOption {
            type = lib.types.lines;
            default = "";
          };
          render = lib.mkOption {
            type = lib.types.lines;
          };
          reload = lib.mkOption {
            type = lib.types.lines;
            default = "";
          };
        };
      }
    );
  };

  options.programs.hot-stylix = {
    enable = lib.mkEnableOption "dynamic Stylix theme switching";

    commandName = lib.mkOption {
      type = lib.types.str;
      default = "hsx";
      description = "Command installed into the user profile.";
    };

    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.xdg.stateHome}/hot-stylix";
      description = "Mutable runtime state directory used for active target files.";
    };

    defaultStyle = lib.mkOption {
      type = lib.types.str;
      default = config.lib.stylix.colors.slug;
      description = "Style name seeded on first activation and used by reset.";
    };

    schemes = lib.mkOption {
      type =
        with lib.types;
        attrsOf (oneOf [
          path
          lines
          attrs
        ]);
      default = { };
      description = ''
        Additional styles keyed by command name.
        Built-in Base16 schemes from `pkgs.base16-schemes` are available automatically.
        Values may be paths, YAML strings, or attribute sets accepted by Stylix.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge ([
      {
        assertions = [
          {
            assertion = config.stylix.enable;
            message = "programs.hot-stylix requires stylix.enable = true";
          }
          {
            assertion = enabledTargetNames != [ ];
            message = "programs.hot-stylix requires at least one enabled target";
          }
          {
            assertion = lib.all (name: builtins.match schemeNamePattern name != null) schemeNames;
            message = "programs.hot-stylix scheme names must match ${schemeNamePattern}";
          }
        ];

        xdg.enable = lib.mkDefault true;
        home.packages = [ cli ];

        home.activation.hotStylix = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          mkdir -p ${lib.escapeShellArg stateDir}

          if [ -s ${lib.escapeShellArg currentStyleFile} ]; then
            current_style="$(cat ${lib.escapeShellArg currentStyleFile})"
          else
            current_style=${lib.escapeShellArg cfg.defaultStyle}
            printf '%s\n' "$current_style" > ${lib.escapeShellArg currentStyleFile}
          fi

          if ! ${lib.getExe cli} set "$current_style"; then
            current_style=${lib.escapeShellArg cfg.defaultStyle}
            printf '%s\n' "$current_style" > ${lib.escapeShellArg currentStyleFile}
            ${lib.getExe cli} set "$current_style"
          fi
        '';
      }
    ])
  );
}
