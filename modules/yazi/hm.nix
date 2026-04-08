{
  config,
  lib,
  hotStylixInputs,
  ...
}:
let
  cfg = config.programs.hot-stylix;
  runtimePath = "${cfg.stateDir}/yazi/theme.toml";
  batTemplatePath = "${hotStylixInputs.stylix.outPath}/modules/bat/base16-stylix.tmTheme.mustache";
in
{
  options.programs.hot-stylix.targets.yazi.enable = lib.mkEnableOption "runtime-managed yazi theme" // {
    default = config.programs.yazi.enable;
  };

  config = lib.mkMerge [
    {
      hotStylix.supportedTargets.yazi = {
        enable = config.programs.hot-stylix.targets.yazi.enable;
        inherit runtimePath;

        shellFunctions = ''
          render_yazi() {
            local scheme_file=$1
            local out_file=$2
            local syntect_file
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

            syntect_file="$(dirname "$out_file")/hot-stylix-current.tmTheme"
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
              ${lib.escapeShellArg batTemplatePath} > "$syntect_file"

            cat > "$out_file" <<EOF
[mgr]
syntect_theme = "$syntect_file"
cwd = { fg = "$base0C" }
find_keyword = { fg = "$base0B", bold = true }
find_position = { fg = "$base0E" }
marker_selected = { fg = "$base0A", bg = "$base0A" }
marker_copied = { fg = "$base0B", bg = "$base0B" }
marker_cut = { fg = "$base08", bg = "$base08" }
border_style = { fg = "$base04" }
count_copied = { fg = "$base00", bg = "$base0B" }
count_cut = { fg = "$base00", bg = "$base08" }
count_selected = { fg = "$base00", bg = "$base0A" }

[indicator]
current = { bg = "$base02", bold = true }
preview = { bg = "$base02", bold = true }

[tabs]
active = { fg = "$base00", bg = "$base0D", bold = true }
inactive = { fg = "$base0D", bg = "$base01" }

[mode]
normal_main = { fg = "$base00", bg = "$base0D", bold = true }
normal_alt = { fg = "$base0D", bg = "$base00" }
select_main = { fg = "$base00", bg = "$base0B", bold = true }
select_alt = { fg = "$base0B", bg = "$base00" }
unset_main = { fg = "$base00", bg = "$base09", bold = true }
unset_alt = { fg = "$base09", bg = "$base00" }

[status]
progress_label = { fg = "$base05", bg = "$base00" }
progress_normal = { fg = "$base05", bg = "$base00" }
progress_error = { fg = "$base08", bg = "$base00" }
perm_type = { fg = "$base0D" }
perm_read = { fg = "$base0A" }
perm_write = { fg = "$base08" }
perm_exec = { fg = "$base0B" }
perm_sep = { fg = "$base0C" }

[pick]
border = { fg = "$base0D" }
active = { fg = "$base0E" }
inactive = { fg = "$base05" }

[input]
border = { fg = "$base0D" }
title = { fg = "$base05" }
value = { fg = "$base05" }
selected = { bg = "$base03" }

[completion]
border = { fg = "$base0D" }
active = { fg = "$base0E", bg = "$base03" }
inactive = { fg = "$base05" }

[tasks]
border = { fg = "$base0D" }
title = { fg = "$base05" }
hovered = { fg = "$base05", bg = "$base03" }

[which]
mask = { bg = "$base02" }
cand = { fg = "$base0C" }
rest = { fg = "$base09" }
desc = { fg = "$base05" }
separator_style = { fg = "$base04" }

[help]
on = { fg = "$base0E" }
run = { fg = "$base0C" }
desc = { fg = "$base05" }
hovered = { fg = "$base05", bg = "$base03" }
footer = { fg = "$base05" }

[filetype]
rules = [
  { mime = "image/*", fg = "$base0C" },
  { mime = "video/*", fg = "$base0A" },
  { mime = "audio/*", fg = "$base0A" },
  { mime = "application/zip", fg = "$base0E" },
  { mime = "application/gzip", fg = "$base0E" },
  { mime = "application/tar", fg = "$base0E" },
  { mime = "application/bzip", fg = "$base0E" },
  { mime = "application/bzip2", fg = "$base0E" },
  { mime = "application/7z-compressed", fg = "$base0E" },
  { mime = "application/rar", fg = "$base0E" },
  { mime = "application/xz", fg = "$base0E" },
  { mime = "application/doc", fg = "$base0B" },
  { mime = "application/pdf", fg = "$base0B" },
  { mime = "application/rtf", fg = "$base0B" },
  { mime = "application/vnd.*", fg = "$base0B" },
  { url = "*/", fg = "$base0D", bold = true },
  { mime = "*", fg = "$base05" }
]
EOF
          }
        '';

        render = ''
          render_yazi "$scheme_file" "$tmp_path"
        '';

        reload = ''
          true
        '';
      };
    }
    (lib.mkIf config.programs.hot-stylix.targets.yazi.enable {
      xdg.configFile."yazi/theme.toml" = lib.mkForce {
        source = config.lib.file.mkOutOfStoreSymlink runtimePath;
      };
    })
  ];
}
