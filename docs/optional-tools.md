# Optional tools

The base template installs its declared tools through Nix and Ghostty through Homebrew. Add tools you actually use, with an explicit installation and update owner.

## Prime Agent

Prime can coexist with Pi. This optional path uses Prime's native installer and updater, while Nix supplies uv. Its application and Python runtime are therefore outside the Nix lock.

Before installation, add this declaration inside the main attribute set in `home.nix`, run `rebuild`, and open a new terminal:

```nix
home.sessionPath = [ "$HOME/.local/bin" ];
```

Confirm `command -v uv` finds the Nix-provided command. Then follow the current [official installation instructions](https://github.com/PrimeIntellect-ai/prime-agent#install). This keeps the vendor's changing installer instructions at their source; the template does not run the installer during a rebuild.

After installation, verify `command -v prime-agent` and `prime-agent --version`, then start it from a project directory. Complete its account setup separately. A successful version check establishes installation, not a successful authenticated model or Python-tool session.

Use `prime-agent update` for updates. The template's `update` script does not invoke Prime's updater; include this command in your attended maintenance if you install Prime. Application versions, Python runtime state, sessions and account credentials are not restored by Nix rollback. Follow the [official documentation](https://github.com/PrimeIntellect-ai/prime-agent) for runtime recovery and extensions appropriate to your installed release.

## Other applications and preferences

Add desired Homebrew casks to `configuration.nix`. Browser, recording, VPN and hardware-control applications remain personal choices; licenses, accounts and first-run permissions are separate from installation. Choose either a supported native updater or a named Homebrew update command for each application, and record that choice in your copy.

Display scaling, account enrollment and device permissions can remain native settings. Record the manual steps you would need to repeat on another Mac. Keep personal hostnames, SSH keys, network policies, licenses and recovery information in their appropriate private locations.

For maintenance, a recurring reminder on a day you choose is sufficient: review pending changes, run `update` while present, check any separately owned applications and Apple updates, and verify your usual workflow. Schedule upgrades around active work and recording sessions; the template does not run unattended upgrades.
