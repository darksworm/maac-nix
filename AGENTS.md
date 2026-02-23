# Repository Guidelines

## Project Structure & Module Organization
- `flake.nix`/`flake.lock`: Flake entry; defines `darwinConfigurations.maac` and Home Manager modules.
- `home.nix`: User-level config (packages, shells, tmux, plugins). Imports `dev/`.
- `darwin/`: nix-darwin modules (system defaults, Homebrew, services).
- `dev/`: Home Manager modules for developer tools (e.g., `k9s.nix`, `jenv.nix`).
- `bin/`: Helper scripts for common workflows (`nix-sync`, `nix-upgrade`, `nix-gc`).
- `zsh-config/`: Shell setup and theme files.
- `theme.nix`/`themes/`: Color theme definitions.

## Build, Test, and Development Commands
- `~/.config/nix/bin/nix-sync`: Rebuild and switch to the latest config; runs GC in background.
- `~/.config/nix/bin/nix-upgrade`: Update inputs and rebuild (flake update + switch).
- `~/.config/nix/bin/nix-gc`: Expire HM generations and collect garbage.
- `darwin-rebuild build --flake ~/.config/nix`: Dry-build to validate evaluation without activating.
- Optional: `home-manager switch --flake ~/.config/nix#ilmars` to apply HM only.

## Coding Style & Naming Conventions
- Nix: 2-space indentation, trailing commas in attribute sets, one option per line.
- Filenames: lowercase, hyphen/snake-case (e.g., `homebrew.nix`, `k9s.nix`).
- Group related options; keep imports explicit. Prefer alphabetical lists for packages/plugins.
- Avoid machine-specific values outside `darwin/`; keep user-specific values in `home.nix`.

## Testing Guidelines
- Prefer dry builds before switching: `darwin-rebuild build --flake ~/.config/nix`.
- If adding flake checks, ensure `nix flake check` passes.
- Validate helper scripts in `bin/` locally; don’t assume network access.

## Commit & Pull Request Guidelines
- Use Conventional Commits where possible: `feat:`, `fix:`, `chore:`, `refactor:`, `docs:`.
- Scope changes: `darwin:`, `home:`, `dev:`, `bin:` (e.g., `feat(home): add zoxide config`).
- PRs: include a concise description, affected modules/paths, rationale, and any activation notes (e.g., “run nix-sync”). Link issues when relevant.

## Security & Configuration Tips
- Never commit secrets (tokens, SSH keys, licenses). Use placeholders and external secret stores.
- Review diffs for accidental credentials; keep personal paths (`/Users/ilmars`) consistent.

## Architecture Notes
- Target: `aarch64-darwin`, primary user `ilmars`.
- Activation source of truth is `flake.nix`; `home.nix` composes user modules, `darwin/` composes system modules.
