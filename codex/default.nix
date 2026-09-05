{
  buildNpmPackage,
  lib,
  stdenv,
}: let
  packageJson = builtins.fromJSON (builtins.readFile ./package.json);
  version = packageJson.dependencies."@openai/codex";
  platformBySystem = {
    aarch64-darwin = {
      package = "codex-darwin-arm64";
      target = "aarch64-apple-darwin";
    };
    x86_64-linux = {
      package = "codex-linux-x64";
      target = "x86_64-unknown-linux-musl";
    };
  };
  platform =
    platformBySystem.${stdenv.hostPlatform.system}
    or (throw "codex does not support ${stdenv.hostPlatform.system}");
in
  buildNpmPackage {
    pname = "codex";
    inherit version;

    src = lib.sources.sourceByRegex ./. [".+\.json"];
    npmDepsHash = lib.removeSuffix "\n" (builtins.readFile ./npm-deps-hash.txt);
    dontNpmBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/bin" "$out/lib/codex"
      cp -R \
        "node_modules/@openai/${platform.package}/vendor/${platform.target}/." \
        "$out/lib/codex/"
      ln -s "$out/lib/codex/bin/codex" "$out/bin/codex"

      runHook postInstall
    '';

    meta = {
      description = "OpenAI Codex CLI";
      homepage = "https://github.com/openai/codex";
      license = lib.licenses.asl20;
      mainProgram = "codex";
      platforms = builtins.attrNames platformBySystem;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
