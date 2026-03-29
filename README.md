# hot-stylix

`hot-stylix` adds instant theme switching to Stylix setups.

Stylix is great at making one theme the source of truth for your system, but changing that theme normally means editing Nix config and rebuilding. `hot-stylix` keeps Stylix as the canonical default, then adds a small runtime layer so you can swap supported app themes with a fast `hsx set <style>` command instead.

Why use it:

- keep Stylix as your source of truth
- switch themes without `nix rebuild`
- persist your current runtime theme across Home Manager activations
- get hot reload for apps that support it
- stay close to Stylix behavior and output formats

Current target:

- Ghostty: theme switching + hot reload

## Structure

- `flake.nix`: top-level flake entrypoint
- `flake/modules.nix`: exports Home Manager modules; dynamically imports every `modules/<app>/hm.nix`
- `flake/hm.nix`: shared Home Manager core for options, CLI generation, scheme handling, and activation
- `flake/checks.nix`: flake checks
- `modules/<app>/hm.nix`: app-specific integration, renderer, and reload hooks

The `modules/` directory is app targets only. Shared logic lives under `flake/`.

## Use

```nix
{
  inputs.hot-stylix.url = "path:/Users/adam/Projects/hot-stylix";

  imports = [
    inputs.hot-stylix.homeManagerModules.default
  ];

  programs.hot-stylix.enable = true;

  stylix.enable = true;
  stylix.base16Scheme = pkgs.base16-schemes + "/share/themes/tokyo-night-dark.yaml";
}
```

Then:

```sh
hsx list
hsx current
hsx set gruvbox-dark-hard
hsx reset
```

## Support Matrix

`Theme switching` means `hot-stylix` can rewrite that target's theme/config.
`Hot reload` means the change is applied to already-running apps without a restart.

This matrix is based on the full target list in the pinned Stylix source. Right now only Ghostty is implemented in `hot-stylix`.

| App | Theme switching | Hot reload |
| --- | --- | --- |
| `alacritty` | No | No |
| `anki` | No | No |
| `ashell` | No | No |
| `avizo` | No | No |
| `bat` | No | No |
| `bemenu` | No | No |
| `blender` | No | No |
| `broot` | No | No |
| `bspwm` | No | No |
| `btop` | No | No |
| `cava` | No | No |
| `cavalier` | No | No |
| `chromium` | No | No |
| `console` | No | No |
| `dank-material-shell` | No | No |
| `discord` | No | No |
| `dunst` | No | No |
| `emacs` | No | No |
| `eog` | No | No |
| `fcitx5` | No | No |
| `feh` | No | No |
| `firefox` | No | No |
| `fish` | No | No |
| `fnott` | No | No |
| `foliate` | No | No |
| `font-packages` | No | No |
| `fontconfig` | No | No |
| `foot` | No | No |
| `forge` | No | No |
| `fuzzel` | No | No |
| `fzf` | No | No |
| `gdu` | No | No |
| `gedit` | No | No |
| `ghostty` | Yes | Yes |
| `gitui` | No | No |
| `glance` | No | No |
| `gnome` | No | No |
| `gnome-text-editor` | No | No |
| `grub` | No | No |
| `gtk` | No | No |
| `gtksourceview` | No | No |
| `halloy` | No | No |
| `helix` | No | No |
| `hyprland` | No | No |
| `hyprlock` | No | No |
| `hyprpanel` | No | No |
| `hyprpaper` | No | No |
| `i3` | No | No |
| `i3bar-river` | No | No |
| `i3status-rust` | No | No |
| `jankyborders` | No | No |
| `jjui` | No | No |
| `k9s` | No | No |
| `kde` | No | No |
| `kitty` | No | No |
| `kmscon` | No | No |
| `kubecolor` | No | No |
| `lazygit` | No | No |
| `lightdm` | No | No |
| `limine` | No | No |
| `mako` | No | No |
| `mangohud` | No | No |
| `micro` | No | No |
| `mpv` | No | No |
| `ncspot` | No | No |
| `neovim` | No | No |
| `nixos-icons` | No | No |
| `noctalia-shell` | No | No |
| `nushell` | No | No |
| `obsidian` | No | No |
| `opencode` | No | No |
| `plymouth` | No | No |
| `qt` | No | No |
| `qutebrowser` | No | No |
| `regreet` | No | No |
| `rio` | No | No |
| `river` | No | No |
| `rofi` | No | No |
| `sioyek` | No | No |
| `spicetify` | No | No |
| `spotify-player` | No | No |
| `starship` | No | No |
| `sway` | No | No |
| `swaylock` | No | No |
| `swaync` | No | No |
| `sxiv` | No | No |
| `tmux` | No | No |
| `tofi` | No | No |
| `vicinae` | No | No |
| `vivid` | No | No |
| `vscode` | No | No |
| `waybar` | No | No |
| `wayfire` | No | No |
| `wayprompt` | No | No |
| `wezterm` | No | No |
| `wob` | No | No |
| `wofi` | No | No |
| `wpaperd` | No | No |
| `xfce` | No | No |
| `xresources` | No | No |
| `yazi` | No | No |
| `zathura` | No | No |
| `zed` | No | No |
| `zellij` | No | No |
| `zen-browser` | No | No |

## Custom Styles

Add custom styles with `programs.hot-stylix.schemes`. Built-in Base16 schemes from `pkgs.base16-schemes` stay available automatically.

Path-backed style:

```nix
{
  programs.hot-stylix.schemes.my-theme = ./themes/my-theme.yaml;
}
```

Inline YAML:

```nix
{
  programs.hot-stylix.schemes.espresso = ''
    scheme: "Espresso"
    author: "Example"
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
}
```

Attrset style:

```nix
{
  programs.hot-stylix.schemes.forest = {
    scheme = "Forest";
    author = "Example";
    base00 = "0b1210";
    base01 = "1d2a25";
    base02 = "2d3c36";
    base03 = "496057";
    base04 = "93a69e";
    base05 = "c7d4ce";
    base06 = "dde7e2";
    base07 = "f4fbf7";
    base08 = "e67e80";
    base09 = "f2a65a";
    base0A = "dbbc7f";
    base0B = "a7c080";
    base0C = "83c092";
    base0D = "7fbbb3";
    base0E = "d699b6";
    base0F = "9da9a0";
  };
}
```

## Notes

- Stylix remains the source for the initial/default style.
- Runtime-selected styles persist across Home Manager activations.
- `hsx` comes from shared logic in `flake/hm.nix`; each supported app is added as `modules/<app>/hm.nix`.
- Ghostty uses a mutable runtime config fragment, so `reload_config` re-reads live colors directly.
- Ghostty reloads in-place on `hsx set` via `SIGUSR2` plus AppleScript `reload_config`.
- First live reload may trigger a macOS Automation prompt for the calling terminal app.
- Add more styles with `programs.hot-stylix.schemes`.
