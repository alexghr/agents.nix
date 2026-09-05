# agents.nix

This is a simple flake to get the latest version of coding agents. The flake automatically updates weekly.

## devenv

To use these packages in a devenv project, add this input to your `devenv.yaml`:

```yaml
inputs:
  agents:
    url: github:alexghr/agents.nix
    flake: false
```

Then import the package set and select Codex in your `devenv.nix`:

```nix
{pkgs, inputs, ...}: let
  agents = import inputs.agents {inherit pkgs;};
in {
  packages = [
    pkgs.git
    agents.codex
  ];
}
```
