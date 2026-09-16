{pkgs}: {
  claude = pkgs.callPackage ./claude {};
  codex = pkgs.callPackage ./codex {};
  pi = pkgs.callPackage ./pi {};
}
