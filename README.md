# hot-stylix

`hot-stylix` adds instant theme switching to Stylix setups.

Stylix is great at making one theme the source of truth for your system, but changing that theme normally means editing Nix config and rebuilding. `hot-stylix` keeps Stylix as the canonical default, then adds a small runtime layer so you can swap supported app themes with a fast `hsx set <style>` command instead.

Why use it:

- keep Stylix as your source of truth
- switch themes without `nix rebuild`
- persist your current runtime theme across Home Manager activations
- get hot reload for apps that support it
- stay close to Stylix behavior and output formats

## Use

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    home-manager.url = "github:nix-community/home-manager";
    stylix.url = "github:danth/stylix";
    hot-stylix.url = "github:adamjhf/hot-stylix";
  };

  outputs = { nixpkgs, home-manager, hot-stylix, ... }: {
    homeConfigurations.me = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs { system = "aarch64-darwin"; };
      modules = [
        stylix.homeModules.stylix
        hot-stylix.homeModules.default
        {
          home.username = "me";
          home.homeDirectory = "/Users/me";
          home.stateVersion = "25.05";

          stylix.enable = true;
          stylix.base16Scheme = nixpkgs.legacyPackages.aarch64-darwin.base16-schemes + "/share/themes/tokyo-night-dark.yaml";

          programs.hot-stylix.enable = true;
        }
      ];
    };
  };
}
```

`hot-stylix.homeModules.default` is the Home Manager module. Import Stylix separately in your config.

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

This matrix is based on the full target list in the pinned Stylix source.

| App | Theme switching | Hot reload |
| --- | --- | --- |
| `alacritty` | ❌ | ❌ |
| `anki` | ❌ | ❌ |
| `ashell` | ❌ | ❌ |
| `avizo` | ❌ | ❌ |
| `bat` | ✅ | ❌ |
| `bemenu` | ❌ | ❌ |
| `blender` | ❌ | ❌ |
| `broot` | ❌ | ❌ |
| `bspwm` | ❌ | ❌ |
| `btop` | ✅ | ❌ |
| `cava` | ❌ | ❌ |
| `cavalier` | ❌ | ❌ |
| `chromium` | ❌ | ❌ |
| `console` | ❌ | ❌ |
| `dank-material-shell` | ❌ | ❌ |
| `discord` | ❌ | ❌ |
| `dunst` | ❌ | ❌ |
| `emacs` | ❌ | ❌ |
| `eog` | ❌ | ❌ |
| `fcitx5` | ❌ | ❌ |
| `feh` | ❌ | ❌ |
| `firefox` | ❌ | ❌ |
| `fish` | ❌ | ❌ |
| `fnott` | ❌ | ❌ |
| `foliate` | ❌ | ❌ |
| `font-packages` | ❌ | ❌ |
| `fontconfig` | ❌ | ❌ |
| `foot` | ❌ | ❌ |
| `forge` | ❌ | ❌ |
| `fuzzel` | ❌ | ❌ |
| `fzf` | ❌ | ❌ |
| `gdu` | ❌ | ❌ |
| `gedit` | ❌ | ❌ |
| `ghostty` | ✅ | ✅ |
| `gitui` | ❌ | ❌ |
| `glance` | ❌ | ❌ |
| `gnome` | ❌ | ❌ |
| `gnome-text-editor` | ❌ | ❌ |
| `grub` | ❌ | ❌ |
| `gtk` | ❌ | ❌ |
| `gtksourceview` | ❌ | ❌ |
| `halloy` | ❌ | ❌ |
| `helix` | ✅ | ❌ |
| `hyprland` | ❌ | ❌ |
| `hyprlock` | ❌ | ❌ |
| `hyprpanel` | ❌ | ❌ |
| `hyprpaper` | ❌ | ❌ |
| `i3` | ❌ | ❌ |
| `i3bar-river` | ❌ | ❌ |
| `i3status-rust` | ❌ | ❌ |
| `jankyborders` | ❌ | ❌ |
| `jjui` | ❌ | ❌ |
| `k9s` | ❌ | ❌ |
| `kde` | ❌ | ❌ |
| `kitty` | ❌ | ❌ |
| `kmscon` | ❌ | ❌ |
| `kubecolor` | ❌ | ❌ |
| `lazygit` | ✅ | ❌ |
| `lightdm` | ❌ | ❌ |
| `limine` | ❌ | ❌ |
| `mako` | ❌ | ❌ |
| `mangohud` | ❌ | ❌ |
| `micro` | ❌ | ❌ |
| `mpv` | ❌ | ❌ |
| `ncspot` | ❌ | ❌ |
| `neovim` | ❌ | ❌ |
| `nixos-icons` | ❌ | ❌ |
| `noctalia-shell` | ❌ | ❌ |
| `nushell` | ❌ | ❌ |
| `obsidian` | ❌ | ❌ |
| `opencode` | ❌ | ❌ |
| `plymouth` | ❌ | ❌ |
| `qt` | ❌ | ❌ |
| `qutebrowser` | ❌ | ❌ |
| `regreet` | ❌ | ❌ |
| `rio` | ❌ | ❌ |
| `river` | ❌ | ❌ |
| `rofi` | ❌ | ❌ |
| `sioyek` | ❌ | ❌ |
| `spicetify` | ❌ | ❌ |
| `spotify-player` | ❌ | ❌ |
| `starship` | ✅ | ✅ |
| `sway` | ❌ | ❌ |
| `swaylock` | ❌ | ❌ |
| `swaync` | ❌ | ❌ |
| `sxiv` | ❌ | ❌ |
| `tmux` | ✅ | ✅ |
| `tofi` | ❌ | ❌ |
| `vicinae` | ❌ | ❌ |
| `vivid` | ❌ | ❌ |
| `vscode` | ❌ | ❌ |
| `waybar` | ❌ | ❌ |
| `wayfire` | ❌ | ❌ |
| `wayprompt` | ❌ | ❌ |
| `wezterm` | ❌ | ❌ |
| `wob` | ❌ | ❌ |
| `wofi` | ❌ | ❌ |
| `wpaperd` | ❌ | ❌ |
| `xfce` | ❌ | ❌ |
| `xresources` | ❌ | ❌ |
| `yazi` | ✅ | ❌ |
| `zathura` | ❌ | ❌ |
| `zed` | ✅ | ❌ |
| `zellij` | ✅ | ✅ |
| `zen-browser` | ❌ | ❌ |

## Custom Styles

Add custom styles with `programs.hot-stylix.schemes`. Built-in Base16 schemes from `pkgs.base16-schemes` stay available automatically.
For file-backed styles, prefer relative Nix path literals from the current flake project.

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

## Structure

- `flake.nix`: top-level flake entrypoint
- `flake/modules.nix`: exports Home Manager modules; dynamically imports every `modules/<app>/hm.nix`
- `flake/hm.nix`: shared Home Manager core for options, CLI generation, scheme handling, and activation
- `flake/checks.nix`: flake checks
- `modules/<app>/hm.nix`: app-specific integration, renderer, and reload hooks

The `modules/` directory is app targets only. Shared logic lives under `flake/`.
