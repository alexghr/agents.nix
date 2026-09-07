# agents.nix

This is a simple flake to get the latest version of coding agents. The flake automatically updates weekly.

Run Codex or Claude Code (marked unfree due to its license) directly:

```sh
nix run github:alexghr/agents.nix#codex
NIXPKGS_ALLOW_UNFREE=1 nix run --impure github:alexghr/agents.nix#claude
```

## devenv

To use these packages in a devenv project, add this input to your `devenv.yaml`:

```yaml
inputs:
  agents:
    url: github:alexghr/agents.nix
    flake: false
```

Then import the package set and select the agents in your `devenv.nix`:

```nix
{pkgs, inputs, ...}: let
  agents = import inputs.agents {inherit pkgs;};
in {
  allowUnfree = true; # Claude Code uses a proprietary license.
  packages = [
    pkgs.git
    agents.codex
    agents.claude
  ];
}
```
