# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal nix-darwin configuration for macOS system management using Nix flakes. It manages system packages, homebrew applications, shell configuration, and development tools.

## Key Commands

### System Management
- `nix-upgrade`: Update flake inputs and rebuild system (runs `nix flake update` + `darwin-rebuild switch`)
- `nix-sync`: Apply current configuration without updating flake inputs (runs `darwin-rebuild switch`)
- `nix-gc`: Garbage collection script (runs automatically after upgrades)

### Development Aliases (available in shell)
- `dc`: Docker compose shortcut
- `argonaut`: Start personal development project (`cd ~/Dev/private/a9s && npm run dev`)
- `devenv`: Access development environment (`cd ~/Dev/devenv && docker-compose`)

## Architecture

### Core Structure
- `flake.nix`: Main flake configuration defining system inputs and outputs
- `darwin/default.nix`: macOS-specific system configuration (nvf/neovim, TouchID, launchd agents, system defaults)
- `home.nix`: Home Manager configuration for user-level packages and shell setup
- `dev/`: Development tool configurations (k9s, jenv)

### Package Management Strategy
- System packages: Managed via `environment.systemPackages` in flake.nix
- User packages: Managed via `home.packages` in home.nix
- GUI applications: Primarily managed through homebrew casks (defined in flake.nix)
- Development tools: Mix of Nix packages and homebrew formulas

### Key Components
- **Neovim**: Configured via nvf module with extensive language support (Nix, TypeScript, Go, Java, Kotlin, etc.)
- **Shell**: Zsh with Prezto, Powerlevel10k, vi-mode, and custom aliases
- **Terminal**: Tmux with custom keybindings and plugins
- **System**: Custom launchd agents, TouchID sudo support, optimized macOS defaults

### Directory Structure
- `bin/`: Custom scripts for system management
- `darwin/`: macOS system-level configurations
- `dev/`: Development tool specific configurations
- `zsh-config/`: Shell configuration files

### Build Process
The system uses darwin-rebuild for applying configurations:
1. Flake inputs define package sources
2. Darwin modules configure system-level settings
3. Home Manager handles user environment
4. Homebrew manages GUI applications and some CLI tools

### Development Environment
- Multiple Java versions managed via jenv (OpenJDK 11, 17, 21)
- Node.js via fnm
- Python via pyenv and uv
- Go and other languages via Nix packages
- Kubernetes tools (kubectl, helm, k9s with custom theme)
- Docker Desktop via homebrew