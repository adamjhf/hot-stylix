# Repository Guidelines

## Project Structure & Module Organization

This repository is a small Nix flake that exports a Home Manager module for runtime theme switching on top of Stylix.

- `flake.nix`: flake inputs, exported Home Manager modules, and flake checks
- `flake.lock`: pinned dependencies
- `flake/modules.nix`: flake exports for Home Manager modules
- `flake/checks.nix`: flake checks
- `flake/hm.nix`: shared Home Manager module logic, CLI generation, runtime state handling
- `modules/<app>/hm.nix`: app-specific Home Manager integration, render logic, and reload hooks
- `README.md`: user-facing setup and support matrix

Keep shared behavior in `flake/hm.nix`. Put per-app support in `modules/<app>/hm.nix`. The `modules/` directory should contain app subdirectories only. The flake dynamically loads every `modules/<app>/hm.nix`.

## Build, Test, and Development Commands

- `nix build --no-link .#checks.aarch64-darwin.default`
  Verifies the module evaluates and builds on Darwin.
- `nix flake check --all-systems --no-build`
  Validates flake outputs and cross-system evaluation without building everything.
- `nix build --no-link .#checks.x86_64-linux.default`
  Optional Linux-target sanity check from the flake.

Use `--no-link` during local iteration to avoid creating a repo-root `result` symlink, which changes the hash of path-based flake inputs.

## Coding Style & Naming Conventions

- Use 2-space indentation in Nix.
- Prefer kebab-case for module/option names, e.g. `programs.hot-stylix`.
- Keep shell in `writeShellApplication` portable and explicit; include required tools in `runtimeInputs` or `PATH`.
- Match Stylix target behavior exactly when implementing app renderers unless there is a documented reason to diverge.

## Testing Guidelines

There is no separate unit test framework yet; the flake checks are the test suite.

- Update or add a flake check when behavior changes.
- Validate both evaluation and build paths when touching scheme discovery, Home Manager activation, or target rendering.
- For runtime changes, smoke test with `hsx list`, `hsx current`, and `hsx set <style>`.

## Commit Guidelines

This repo does not have established history yet. Use Conventional Commits:

- `feat: add kitty target scaffold`
- `fix: align ghostty renderer with stylix`

## Syncing with Stylix

When Stylix updates, keep `README.md` and app support in sync.

- Sync the README support matrix from the pinned Stylix source, not memory. Get the full target list from Stylix `modules/` and update the matrix for any added or removed apps. Mark unsupported apps as `No / No` until implemented.
- For a new app, inspect Stylix’s module first and mirror its rendered theme output as closely as possible. Reuse Stylix’s color mapping, naming, and file format so `hot-stylix` stays predictable.
- Minimum support goal for each app: theme switching through `hsx set <style>`, even if the app still requires restart.
- Preferred implementation shape per app:
  1. add `modules/<app>/hm.nix`
  2. register the target entry under `supportedTargets` from that app module
  3. keep shared CLI/state/scheme logic in `flake/hm.nix`
  4. define a stable runtime path under `~/.local/state/hot-stylix/<app>/...`
  5. add a renderer that converts Base16 scheme data into the app’s theme/config format
  6. wire the target into `hsx set`
  7. add a reload hook only if the app has a reliable live-reload mechanism
- Prefer consistent mechanics across apps: mutable runtime file, persistent current style, best-effort reload hook, and no rebuild required for switching.
- Hot reload methods vary by app. Prefer official CLI/API reloads first, then documented signals, then platform automation hooks only when necessary.

## Configuration Notes

`hot-stylix` requires both Home Manager and Stylix. It reuses Stylix as the color source of truth and writes mutable runtime files under `~/.local/state/hot-stylix`.
