{
  fetchurl,
  lib,
  stdenvNoCC,
}: let
  packageJson = builtins.fromJSON (builtins.readFile ./package.json);
  packageLock = builtins.fromJSON (builtins.readFile ./package-lock.json);
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
    platformBySystem.${stdenvNoCC.hostPlatform.system}
    or (throw "codex does not support ${stdenvNoCC.hostPlatform.system}");
  platformPackage = packageLock.packages."node_modules/@openai/${platform.package}";
in
  stdenvNoCC.mkDerivation {
    pname = "codex";
    inherit version;

    src = fetchurl {
      url = platformPackage.resolved;
      hash = platformPackage.integrity;
    };
    dontConfigure = true;
    dontBuild = true;
    # Preserve upstream binaries and their signatures.
    dontStrip = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/bin" "$out/lib/codex"
      cp -R \
        "vendor/${platform.target}/." \
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
