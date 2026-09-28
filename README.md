# dotfiles

One folder that sets up a Mac for working with coding agents: the settings, the apps, the command-line tools, and four coding agents ([Claude Code](https://code.claude.com/docs), [Codex](https://github.com/openai/codex), [opencode](https://opencode.ai), [Pi](https://github.com/earendil-works/pi)). On a fresh Mac, run one script to set it up. After that, edit a file and run `rebuild`. The files are commented.

This is a template. Build from it first, then edit the files.

**Follow the walkthrough:** [Watch the YouTube video](https://www.youtube.com/watch?v=V6F_JJnnKLI) · [Read the companion guide](https://agenteer.com/learn/tutorials/mac-setup-agentic-engineering/). The video shows the original setup; use this README for the current installation and update commands.

Under the hood: [Nix](https://nixos.org) installs the software and pins the versions in `flake.lock`, [nix-darwin](https://github.com/nix-darwin/nix-darwin) writes the Mac settings, [home-manager](https://home-manager.dev) sets up your account, and [Homebrew](https://brew.sh) supplies the Mac apps.

## What the build puts on the Mac

- [Nix](https://nixos.org), installed by [Determinate](https://determinate.systems).
- Mac settings, and Touch ID for `sudo`.
- [Homebrew](https://brew.sh), and the Mac apps it installs: [Ghostty](https://ghostty.org), a terminal. Add your own apps to the same list.
- The [Hack Nerd Font](https://www.nerdfonts.com).
- Command-line tools: [ripgrep](https://github.com/BurntSushi/ripgrep) (search inside files), [jq](https://jqlang.org) (read JSON), [lazygit](https://github.com/jesseduffield/lazygit) (git on one screen), git, [gh](https://cli.github.com) (GitHub from the terminal), and [uv](https://docs.astral.sh/uv/) (Python projects and dependencies).
- [Neovim](https://neovim.io) with [LazyVim](https://www.lazyvim.org): file search, completion, language tools, formatting and Git access inside the terminal. Node.js, Python, language servers, formatters and compiled parsers are supplied by Nix. New to the editor: run `nvim`, then type `:Tutor` and press Enter.
- [tmux](https://github.com/tmux/tmux/wiki): detach and reconnect to running sessions while the Mac remains running. Saves window/pane layouts and working directories for recovery into fresh shells; running agents are not restarted after a reboot.
- [zsh](https://www.zsh.org), the Mac's default shell, with a [starship](https://starship.rs) prompt.
- Coding agents: [Claude Code](https://code.claude.com/docs), [Codex](https://github.com/openai/codex), [opencode](https://opencode.ai), and [Pi](https://github.com/earendil-works/pi), with one shared instructions file, `home/AGENTS.md`.

## Read this before you run it

- **Fresh Mac setup.** The instructions below set up a fresh Mac. Read `configuration.nix`, `home.nix` and `modules/` to see the system settings, applications and user configuration they apply.
- **Tested on [Apple Silicon](https://support.apple.com/en-us/116943).** Apple menu → About This Mac shows which chip you have. On an Intel Mac, change `system = "aarch64-darwin";` in `flake.nix` to `"x86_64-darwin"`.
- **Your username.** The script writes your macOS username into `flake.nix`. Your git name and email are not in the folder, and git refuses your first commit until you add them. See "Make it yours" below.
- **No secrets live here.** Run each agent once and it walks you through signing in. This folder holds no keys, tokens, or passwords.

## Build the Mac

On a fresh Mac, open Terminal and check for git:

```sh
git --version
```

If macOS offers to install the Command Line Tools, click Install and wait for it to finish.

Clone it, one of two ways:

- **Quick start:** this repo.
  ```sh
  git clone https://github.com/agenteer/dotfiles.git ~/dotfiles
  ```
- **Your own copy**, to make changes and keep them: make a copy first, with **Use this template** or **Fork**, then clone it.
  ```sh
  git clone https://github.com/YOUR-NAME/YOUR-REPO.git ~/dotfiles
  ```

Then run the script:

```sh
cd ~/dotfiles
./bootstrap.sh
```

### What the script does

`bootstrap.sh` runs these steps, in order:

1. Installs [Determinate Nix](https://determinate.systems). Its installer asks for your password.
2. Links this folder to a fixed place, `~/.dotfiles`, so the files can be found wherever you cloned it.
3. Sets `user` in `flake.nix` to your macOS username, if it differs.
4. Completes the version list, `flake.lock`.
5. Builds the system half from `configuration.nix`. Runs as root, so it may ask for your password again.
6. Builds your account half from `home.nix`. No password: this half does not run as root.

It takes a few minutes. When it finishes, open a new terminal window; existing windows do not see the new tools.

## After that

In a new terminal, `rebuild` and `update` work from any directory. They call this repository’s scripts through `~/.dotfiles`. Use `rebuild` to apply your declarations with the existing lock; use `update` to select newer Nix inputs, apply both configurations and upgrade Ghostty. The scripts can also be run directly from the repository.

Start with the [editor, terminal and shortcuts guide](docs/editor-workflow.md). [Optional tools](docs/optional-tools.md) explains Prime Agent and additional app choices.

Both `./rebuild.sh` and `./update.sh` activate the system configuration, so either may ask for Touch ID or your password. Run them while you can respond.

### Change something

Edit `configuration.nix` for system settings and apps, `home.nix` for tools and shell, or `modules/` for editor and terminal settings. Then apply the change:

```sh
./rebuild.sh
```

Add a package line to install it. Removing a Nix package line removes it from the managed environment after a rebuild; removing a Homebrew declaration leaves the installed app alone. Uninstall Homebrew apps explicitly when intended, after preserving their data.

The script builds both configurations using the existing `flake.lock`, refusing implicit lock updates, then activates your account and the system. A build failure stops before activation. The two activations are not atomic: if the second fails, the first may already be active. The output names default to your username and `mac`; set `HM_PROFILE` or `DARWIN_HOST` when you rename those outputs. Files under `home/` are linked into place, so an edit there can take effect without a rebuild.

### Update

Review and commit pending configuration changes first. Then, when you want newer versions:

```sh
./update.sh             # refreshes the lock, rebuilds both halves, then upgrades Ghostty
git diff -- flake.lock  # review the input revisions selected by Nix
git add flake.lock
git commit -m "Update Nix inputs"
```

The script stops at the first failure. Check the resulting environment before committing the new lock. It does not automatically commit, delete old Nix generations, or run Homebrew Bundle cleanup to uninstall undeclared apps or zap their data. Homebrew may still clean old versions and caches during upgrades.

**Update ownership:** Nix packages follow `flake.lock`. This template currently disables Ghostty's native updater in `modules/terminal.nix`, so `update.sh` explicitly upgrades Ghostty through Homebrew. Ghostty is the only Homebrew app included here. If you add more applications, decide which updater owns each one: either its native updater or a named Homebrew upgrade in `update.sh`. Do not assume every application updates only through this script. macOS and App Store updates remain separate, as does the Determinate Nix runtime.

Homebrew application versions are not pinned by `flake.lock`; they may change independently. Rebuilding a Nix generation does not restore an earlier GUI-app version or application data. See [Homebrew's update behavior](https://docs.brew.sh/FAQ#how-do-i-update-my-local-packages).

A weekly reminder to run this attended maintenance is a useful starting point. Choose your own day in your calendar or reminders app; this template does not install a scheduler. Editor plugins have a separate lock and update procedure in the [workflow guide](docs/editor-workflow.md#updates).

### Go back

Keep a known-good commit and backups of your files and application data. If an input upgrade fails, restore only the previous lock, preserving unrelated work:

```sh
git restore --source=YOUR_KNOWN_GOOD_COMMIT -- flake.lock
./rebuild.sh
```

Review the diff first. This recovery applies the previous inputs with the current safe Homebrew settings. Do not blindly activate an older system generation: versions of this template before the safety fix used `cleanup = "zap"`, which could remove undeclared apps and their associated data. Nix rollback is not a substitute for a data backup.

### Try a tool without adding it

```sh
nix shell nixpkgs#<tool>    # gone when you close the window
brew install <tool>         # remains installed; declare it if it belongs in your rebuildable setup
./whats-not-declared.sh     # lists what is on the Mac that this folder does not account for
```

### Make it yours

- **Git identity.** Add `programs.git.settings.user = { name = "Your Name"; email = "you@example.com"; };` inside the main attribute set in `home.nix`, then run `rebuild`.
- **GitHub, once.** `gh auth login`, choose SSH, and let it generate and upload a key for this Mac. Then point your copy at its SSH address, `git remote set-url origin git@github.com:YOUR-NAME/YOUR-REPO.git`, and `git push` then uses the SSH key instead of asking for a login.
- **Apps.** One line each in `configuration.nix`; record the update owner as described above.
- **Keep personal changes private.** If your copy will contain personal infrastructure details, create a private repository from this template. Keep credentials outside both the repository and Nix expressions; private Git is not a secret store.

## What it does not cover

What you still do by hand:

- Apple's Command Line Tools (the `git --version` prompt).
- Your git name and email, the sign-in to each coding agent, and the sign-in to GitHub with its SSH key.
- An Apple ID, if you want one. No line in these files requires one.
- macOS updates, first-run permissions an app asks for, and Bluetooth pairing.

## What is in the folder

- `flake.nix`: the entry point. What the folder depends on, which release each dependency follows, and the one `user =` line.
- `configuration.nix`: the system. macOS settings, the font, Touch ID for `sudo`, Homebrew and its app list. Needs your password to apply.
- `home.nix`: your account. Command-line tools, four coding agents, zsh, the prompt and shared instructions. Imports the editor and terminal modules. User activation does not run as root.
- `modules/editor.nix`: Neovim, language tools and Nix-owned parsers.
- `modules/terminal.nix`: Ghostty and tmux, including layout recovery.
- `home/`: linked configuration, including the LazyVim plugin lock, `.claude/settings.json`, and the instructions file shared by all four agents.
- `docs/`: everyday workflow, shortcuts and optional setup.
- `bootstrap.sh`: the first build on a fresh Mac.
- `rebuild.sh`: applies a change to `configuration.nix` or `home.nix`.
- `update.sh`: updates the lock, invokes `rebuild.sh` for both configurations, then upgrades Homebrew-owned Ghostty.
- `whats-not-declared.sh`: lists what is on the Mac that these files do not account for.

## Credits

Inspired by [Kun Chen's dotfiles](https://github.com/kunchenguid/dotfiles) (MIT-0).

## License

[MIT No Attribution](LICENSE).
