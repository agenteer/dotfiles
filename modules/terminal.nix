# User-level tmux and Ghostty settings, reusable independently of system configuration.
{ config, lib, pkgs, ... }:
let
  # Layout metadata can contain working paths and command arguments. Keep it local and private.
  tmuxStateDir = "${config.xdg.stateHome}/tmux/resurrect";
in {
  home.activation.tmuxResurrectState = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    run ${pkgs.coreutils}/bin/install -d -m 0700 ${lib.escapeShellArg tmuxStateDir}
  '';
  programs.tmux = {
    enable = true;
    keyMode = "vi";
    mouse = true;
    escapeTime = 0;
    plugins = [
      {
        plugin = pkgs.tmuxPlugins.resurrect;
        extraConfig = ''
          set -g @resurrect-dir "${tmuxStateDir}"
          set -g @resurrect-processes 'false'
          set -g @resurrect-capture-pane-contents 'off'
          set -g @resurrect-never-overwrite 'on'
        '';
      }
      {
        # Continuum must load last. Save layouts, not running processes or terminal output.
        plugin = pkgs.tmuxPlugins.continuum;
        extraConfig = ''
          set -g @continuum-save-interval '15'
          set -g @continuum-restore 'on'
          set -g @continuum-boot 'off'
        '';
      }
    ];
    extraConfig = ''
      set -g default-terminal "tmux-256color"
      set -ag terminal-overrides ",xterm-256color:RGB"
      set -g allow-passthrough on
      set -s extended-keys on
      set -s extended-keys-format csi-u
      set -as terminal-features "xterm*:extkeys"
    '';
  };
  programs.ghostty = {
    enable = true;
    package = null;
    settings = {
      # Preserve this template's existing owner: update.sh upgrades Ghostty through Homebrew.
      auto-update = "off";
      font-family = "Hack Nerd Font";
      font-size = 15;
      window-inherit-font-size = false;
    };
  };
}
