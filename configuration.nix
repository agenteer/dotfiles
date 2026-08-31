{ pkgs, user, system, ... }:

{
  # why: Determinate installs AND manages the Nix engine, so nix-darwin must not manage it too. The engine stays on.
  nix.enable = false;

  # (No license exception in this file: nothing it installs carries a non-free license.
  # The coding agents' licenses are allowed in flake.nix, on the home-folder side where they live.)

  # why: the kind of Mac; it comes from the single `system =` line in flake.nix so both halves cannot disagree.
  nixpkgs.hostPlatform = system;

  # why: nix-darwin needs one user to own user-scoped settings (Homebrew, defaults).
  system.primaryUser = user;
  users.users.${user} = {
    home = "/Users/${user}";
  };

  # why: "I started on release 7's defaults" - a later release cannot silently change them. Set once.
  system.stateVersion = 7;

  # why: the Mac settings otherwise clicked through in System Settings, written down.
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      # hold the letter a: a pause, then aaaaa. InitialKeyRepeat is the pause; KeyRepeat is the gap between each a.
      KeyRepeat = 2;          # ~30 ms between repeats (Apple's default is slower)
      InitialKeyRepeat = 15;  # ~a quarter-second pause before repeating starts
      AppleShowAllExtensions = true;  # Finder always shows .md, .nix, every extension
      _HIHideMenuBar = true;  # the menu bar hides until the mouse reaches the top edge; more room while working
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # Finder opens folders as a list ("Nlsv" is Apple's code for list view)
    finder.CreateDesktop = false;          # files on the Desktop are not drawn there; the desktop stays empty
    trackpad.Clicking = true;              # a tap on the trackpad counts as a click
  };

  # why: the font the terminal and editor use, installed where macOS registers fonts (/Library/Fonts/Nix Fonts).
  # In the home folder alone, Mac apps such as the terminals could not see it.
  fonts.packages = [ pkgs.nerd-fonts.hack ];

  # why: Touch ID (or Apple Watch) instead of a typed password for sudo.
  security.pam.services.sudo_local.touchIdAuth = true;
  # why: without this, Touch ID does not reach a command run inside tmux and sudo falls back to asking for the typed password.
  security.pam.services.sudo_local.reattach = true;

  # why: Homebrew installed under Nix's control, never the standalone installer.
  nix-homebrew = {
    enable = true;
    inherit user;
    # why: on a Mac that already has Homebrew, take it over instead of stopping the build. On a fresh Mac this does nothing.
    autoMigrate = true;
  };

  # why: the Mac apps only Homebrew has - things with a window and an icon - declared here so the app list is auditable.
  homebrew = {
    enable = true;
    onActivation.cleanup = "zap";  # every rebuild removes any Homebrew app not on this list, leftovers included
    onActivation.autoUpdate = false;  # a rebuild does exactly what the diff says; the Mac apps move only when ./update.sh asks
    # why --force: if an app on the list is already on the Mac from a by-hand install, replace it
    # with the listed one instead of stopping the build. On a fresh Mac this flag does nothing.
    onActivation.extraFlags = [ "--force" ];
    # why: only what Nix cannot install from the formula side; the coding agents are in home.nix, pinned by flake.lock.
    brews = [ ];       # command-line programs from Homebrew; empty on purpose, the command-line tools come from Nix
    casks = [
      "ghostty"        # the terminal; its settings are a few lines in home.nix, not a preferences window
    ];
    # why so short: the template carries only what the setup needs. Your own apps are your
    # first additions - one line each.
  };
}
