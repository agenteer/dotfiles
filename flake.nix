{
  description = "A Mac, declared";

  inputs = {
    # why: pinned to a stable release so versions move only when this file moves.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    # why: a package set that moves daily ("unstable" = changes every day, not broken), kept for anything that must be newer than the May snapshot.
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    # why: the user's side (dotfiles, tools, the coding agents) from the same package set.
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # why: installs Homebrew itself under Nix, so Mac apps are declared too.
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, home-manager, nixpkgs, nixpkgs-unstable }:
    let
      # The one username line to change if this isn't your machine.
      # bootstrap.sh rewrites this for you if your macOS username differs.
      user = "your-username";
      # why: the kind of Mac, named once so both halves below agree. An Intel Mac changes this one word to "x86_64-darwin".
      system = "aarch64-darwin";
      # why: the pinned package set, used for everything in home.nix except the three agents.
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      # why: the newest package set, used only for the three coding agents in home.nix.
      pkgsUnstable = import nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    in
    {
      # why: "mac" is the label rebuild.sh and bootstrap.sh look up; it does not
      # need to match the computer's name, so nothing else changes per machine.
      # This half is the SYSTEM: settings every account sees, and the Mac apps. It needs your password.
      darwinConfigurations."mac" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user system; };
        modules = [
          ./configuration.nix
          nix-homebrew.darwinModules.nix-homebrew
        ];
      };

      # why: this half is YOUR ACCOUNT - tools, shell, editor, and the three coding agents.
      # why it needs no password: it activates nothing as root. (Nix still writes to /nix and to your
      # profile through its daemon, so the honest claim is "no root activation", not "touches nothing".)
      # why the name is your username: `home-manager switch --flake ~/.dotfiles` then finds it on its own.
      # Both halves read the one flake.lock, so a version moves in both places or neither.
      homeConfigurations."${user}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit user pkgsUnstable; };
        modules = [ ./home.nix ];
      };
    };
}
