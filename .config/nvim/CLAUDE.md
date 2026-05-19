# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Neovim configuration using **native Neovim package management** (`vim.pack`) — no external plugin manager (no lazy.nvim, packer, etc.). The configuration is intentionally flat: a single `init.lua` entry point plus a language-specific `lua/java_config.lua`.

## Plugin Management

Plugins are declared in `init.lua` via `vim.pack.add({...})`. Exact versions are pinned in `nvim-pack-lock.json` (auto-generated, do not edit manually). To update plugins, use Neovim's built-in `:pack` commands.

## Architecture

- **`init.lua`** — Single file containing all settings, plugin declarations, keymaps, LSP/DAP/Treesitter setup, and autocommands.
- **`lua/java_config.lua`** — Loaded only on `FileType java` via autocommand; configures JDTLS with SDKMAN-managed runtimes (Java 8/11/17/21/25), debug adapter bundles, and Lombok support.
- **`nvim-pack-lock.json`** — Auto-generated lock file tracking plugin commit SHAs.

## Key Design Decisions

- **Completion**: Uses Neovim's built-in `vim.lsp.completion` (no external completion plugin like nvim-cmp).
- **File navigation**: Both Telescope and Mini.pick are configured; Mini.pick is the primary file picker (`<leader>f`) using ripgrep.
- **Oil.nvim** replaces netrw for file browsing (opened with `-`).
- **DAP**: Configured for LLDB (C/C++/Rust debugging). Java debugging is handled separately in `java_config.lua`.
- **Treesitter**: Loaded with `pcall()` fallback. Parser auto-installation is enabled.
- **Mason** handles automatic LSP/tool installation.

## Leader Key & Key Mappings

Leader: `<Space>`

| Key | Action |
|-----|--------|
| `<leader>f` | File picker (Mini.pick + ripgrep) |
| `<leader>h` | Help picker |
| `<leader>w` | Write file |
| `<leader>q` | Quit |
| `<leader>o` | Write and source config |
| `<leader>gf` | Format buffer |
| `<leader>ca` | Code action |
| `<leader>d` | DAP debug new |
| `<C-b>` | Toggle breakpoint |
| `-` | Oil file browser |
| `gh` | LSP hover |
| `gd` / `gD` | Go to definition / declaration |
| `gi` / `gr` | Go to implementation / references |
| `gs` | Workspace symbols |
| `<F2>` | LSP rename |
| `=` | LSP format |
| `g]` / `g[` | Next/previous diagnostic |

## Adding New Plugins

Add entries to the `vim.pack.add({...})` table in `init.lua`. Configuration for the plugin should follow immediately in `init.lua`, or in a new file under `lua/` triggered by an autocommand (as done for Java).

## Java Setup

`lua/java_config.lua` expects SDKMAN at `~/.sdkman/candidates/java/` with installations for versions 8, 11, 17, 21, and 25. JDTLS itself should be installed via Mason. Debug/test bundles are sourced from Mason's install directory.
