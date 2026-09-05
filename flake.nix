{
  description = "A flake to install coding agents";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = inputs: {
    packages = builtins.mapAttrs (system: pkgs: {
      hello = pkgs.hello;

      default = inputs.self.packages.${system}.hello;
    }) inputs.nixpkgs.legacyPackages;
  };
}
