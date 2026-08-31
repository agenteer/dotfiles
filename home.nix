{ config, lib, pkgs, pkgsUnstable, user, ... }:

let
  # why: a fixed path to this repo, so links below work wherever it was cloned.
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  # why: records the defaults home-manager started with; set once at install.
  home.stateVersion = "26.05";

  # why: installs the `home-manager` command, which is what rebuilds this half of the machine.
  programs.home-manager.enable = true;
  # why: home-manager otherwise ends every rebuild with "N unread news items"; the news is for module authors, not for you.
  news.display = "silent";

  # why: the tools on the path, from the pinned package set.
  home.packages = with pkgs; [
    # cli used constantly
    ripgrep     # rg word: search inside every file in a folder, in a second
    jq          # reads JSON on the command line; the status line under Claude's prompt needs it
    lazygit     # a full-screen git view: every change an agent made, staged and committed with one key
    git         # version control
    gh          # GitHub from the terminal
    neovim      # the editor
    # why: the three coding agents come from the daily package set, not the pinned May one, because they ship
    # several times a week and a month-old agent is a worse agent.
    # Which day's build you get is still fixed by flake.lock, so ./update.sh moves them and the diff shows it.
    pkgsUnstable.claude-code   # Claude Code (the command is `claude`)
    pkgsUnstable.codex         # OpenAI Codex
    pkgsUnstable.opencode      # the open-source harness; the third reader of the one instructions file
  ];
  # why: the font is NOT here but in configuration.nix - a font in this list is a file macOS never looks at.

  home.sessionVariables.EDITOR = "nvim";

  # why: git is on, but WHO authors commits is deliberately not in this public file. Your first edit:
  # add settings.user = { name = "Your Name"; email = "you@example.com"; }; git refuses to commit until you do.
  programs.git.enable = true;
  # why: without this, git guesses an author from your account name and the Mac's hostname and commits with that. This makes it refuse until name and email are set.
  programs.git.settings.user.useConfigOnly = true;

  # why: the Mac's default shell, with the two things that make it pleasant.
  programs.zsh = {
    enable = true;
    # why: the folder keeps its shell config in ~/.config/zsh, so ~/.zshrc stays an ordinary file you (or an
    # installer script that "adds a line to your .zshrc") can write to. The managed config reads it last.
    dotDir = "${config.home.homeDirectory}/.config/zsh";
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = lib.mkMerge [
      ''
        bindkey '^f' autosuggest-accept
      ''
      # why: read ~/.zshrc last. Anything an installer put there works; ./whats-not-declared.sh shows it to you.
      (lib.mkOrder 1500 ''
        [ -f "$HOME/.zshrc" ] && source "$HOME/.zshrc"
      '')
    ];
    # why: three shortcuts, and only three - the ones typed dozens of times a day. The agents do the rest of git.
    shellAliases = {
      ".." = "cd ..";
      pull = "git pull";
      st = "git status";   # git status, typed often
    };
  };

  # why: a clean prompt: folder, git branch, how long the last command took.
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
      # why: these two modules are on by default and print your cloud account email and project id in the
      # prompt, where any screenshot or shared screen picks them up. Off, unless you want them.
      gcloud.disabled = true;
      aws.disabled = true;
    };
  };

  # why: several agent sessions side by side that survive a closed window, a quit terminal, or a dropped
  # remote connection; the one multiplexer Claude Code's own split-pane mode runs on.
  programs.tmux = {
    enable = true;
    keyMode = "vi";           # h/j/k/l in copy mode, like the editor
    mouse = true;             # click a pane to focus it; scroll agent output
    escapeTime = 0;           # Esc reaches Neovim at once instead of after a pause
    extraConfig = ''
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"   # true color for the theme
    '';
  };

  # why: edit in place — the real file stays in this repo; ~/.config just points at it.
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
  home.file.".claude/settings.json".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.claude/settings.json";

  # why: the terminal's settings, written by the folder into ~/.config/ghostty/config. The app itself comes from
  # Homebrew (package = null: nixpkgs has no Mac build). auto-update off: nothing this folder installs updates on its own.
  # A hand-written config in ~/Library/Application Support/com.mitchellh.ghostty wins over this file - delete it first.
  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      auto-update = "off";
      font-family = "Hack Nerd Font";
      font-size = 15;
    };
  };

  # why: one instructions file, AGENTS.md, linked into the place each agent reads its own from.
  home.file.".claude/CLAUDE.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
  home.file.".config/opencode/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
}
