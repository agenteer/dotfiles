# Editor, terminal and shortcuts

Open Ghostty, change into your project, then run `nvim`. On first launch, Git downloads the plugin versions recorded in `home/.config/nvim/lazy-lock.json`; an Internet connection is required. Nix has already supplied Neovim, language tools and compiled parsers. LazyVim is the editor configuration; Lazygit is the separate Git interface you can open from it.

Press Escape to enter **Normal mode**, where keys operate the editor. Press `i` to enter **Insert mode**, where you type text. `Space f f` means press those three keys in sequence in Normal mode. `Control+B` means hold Control and press B.

## Everyday keys

| Where | Keys | Action |
| --- | --- | --- |
| Neovim, Normal mode | Space, then wait | Show available command groups |
| Neovim, Normal mode | `Space f f` | Find a project file |
| Neovim, Normal mode | `:e filename` then Enter | Open a named file |
| Neovim, Normal mode | `:w` then Enter | Save the current file |
| Neovim, Normal mode | `:q` then Enter | Close the window; refuses unsaved changes |
| Neovim, Normal mode | `Space c f` | Format explicitly |
| Neovim, Normal mode | `Space g g` | Open Lazygit for the project |
| Neovim, Normal mode | `Space f t` | Open a terminal on the right |
| Neovim, terminal input | Control+backslash, then Control+N | Return to terminal Normal mode; `i` resumes typing into the terminal |
| Neovim, Normal mode | Control+H/J/K/L | Move to the left/lower/upper/right editor window |
| Code completion, Insert mode | Control+N / Control+P | Select next / previous suggestion |
| Code completion, Insert mode | Control+Y | Accept a suggestion; Tab primarily moves through snippet fields |
| `:` command completion | Tab / Shift+Tab | Cycle matching commands or filenames |
| `:` command completion | Control+Y, then Enter | Accept the match, then execute the command |
| Ghostty | Command+plus / Command+minus | Enlarge / shrink this terminal's text |
| Ghostty | Command+0 | Reset to the declared 15-point font |

Arrow keys and Tab do not mean the same thing in every mode. For example, `:e tu` uses command-line completion: use Tab to choose a filename, then Enter to open it. It is separate from the completion menu shown while editing code. These are language-server, buffer, path and snippet suggestions; this template does not configure an AI completion service.

Saving and formatting are deliberate actions here. Automatic saving and format-on-save are disabled. Native language indentation and project EditorConfig settings remain active. When an agent changes a file you also have open, resolve any unsaved editor changes before reloading; do not discard them merely to see the agent's version.

Ghostty's temporary font zoom does not edit Nix. New windows use the declared size instead of inheriting the enlarged size.

## tmux

Start a named session with `tmux new -s work`. Reconnect using `tmux attach -t work`; `tmux ls` lists your sessions. Closing a terminal or detaching leaves processes running in the tmux server, provided the host remains running.

For each prefixed shortcut, press Control+B, release it, then press the next key:

| Keys after the prefix | Action |
| --- | --- |
| `d` | Detach, leaving the session running |
| `c` | Create a window |
| `n` / `p` | Next / previous window |
| `%` / `"` | Split side by side / top and bottom |
| Arrow key | Move between panes |
| `z` | Toggle the active pane filling the window |
| `[` | Enter scrollback mode; use Control+U / Control+D to move half a page, `q` to leave |
| Control+S | Save the layout now |
| Control+R | Restore the saved layout |

Control+H/J/K/L belong to Neovim; tmux does not intercept them globally. Modified keys are enabled in tmux so applications can distinguish combinations such as modified Enter when supported by the terminal and application.

Continuum is configured to save every 15 minutes and restore when a new tmux server starts. It does not launch tmux at macOS login. Multiple tmux servers can suppress automatic restoration; the manual save/restore keys remain available. Recovery restores arrangements and directories into shells, not running agents or past terminal output. Existing panes are preserved.

Layout metadata stays in `~/.local/state/tmux/resurrect`, in a private directory. It can still contain local paths and command metadata: keep it outside Git and public screenshots.

## Updates

| Component | Owner and procedure |
| --- | --- |
| Neovim, agents including Pi, uv, language tools, parsers and tmux plugins | Nix: run `update`; `flake.lock` records input revisions |
| LazyVim and Lua editor plugins | Lazy: `:Lazy update`; review and commit `home/.config/nvim/lazy-lock.json` after testing |
| Ghostty app | Homebrew: included in `update` |
| Your project's JavaScript/Python dependencies | The project's package manager and lock; separate from the installed agent CLI |

LazyVim itself is constrained to 16.0.1 in `lua/config/lazy.lua`; moving to another distribution version requires an explicit configuration change and compatibility check. Automatic plugin update checks are disabled. Keep plugin upgrades separate from Nix upgrades so a failure is easier to identify. After a deliberate plugin update, restart Neovim, check completion/indentation/formatting in the languages you use, and review the lock diff. To return to a known-good plugin lock, restore that file from your known-good commit and run `:Lazy restore`.

The Nix parser bundle and the editor plugin set must remain compatible. If a Nix upgrade produces editor errors, preserve the error and return to the previous known-good Nix lock while investigating; avoid adding competing parser or Mason installations. The same principle applies when you add another language: declare its external tools in `modules/editor.nix` and its editor configuration under `home/.config/nvim`.

`pi` invokes the installed CLI. A tutorial that imports Pi's SDK can declare a separate project dependency in package.json; its lock controls that project's library version. Installing such a dependency is not required merely to run the CLI in that project.
