{
  fetchurl,
  lib,
  stdenvNoCC,
  makeBinaryWrapper,
  autoPatchelfHook,
  alsa-lib,
  procps,
  ripgrep,
  bubblewrap,
  socat,
}: let
  packageJson = builtins.fromJSON (builtins.readFile ./package.json);
  packageLock = builtins.fromJSON (builtins.readFile ./package-lock.json);
  version = packageJson.dependencies."@anthropic-ai/claude-code";
  platformBySystem = {
    aarch64-darwin = "darwin-arm64";
    x86_64-linux = "linux-x64";
  };
  platform =
    platformBySystem.${stdenvNoCC.hostPlatform.system}
    or (throw "claude does not support ${stdenvNoCC.hostPlatform.system}");
  platformPackage = packageLock.packages."node_modules/@anthropic-ai/claude-code-${platform}";
in
  stdenvNoCC.mkDerivation {
    pname = "claude-code";
    inherit version;

    src = fetchurl {
      url = platformPackage.resolved;
      hash = platformPackage.integrity;
    };
    dontConfigure = true;
    dontBuild = true;
    # Stripping breaks the embedded Bun application and Darwin signatures.
    dontStrip = true;

    nativeBuildInputs =
      [makeBinaryWrapper]
      ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [autoPatchelfHook];

    installPhase = ''
      runHook preInstall

      install -Dm755 claude "$out/bin/claude"
      wrapProgram "$out/bin/claude" \
        --set DISABLE_AUTOUPDATER 1 \
        --set DISABLE_INSTALLATION_CHECKS 1 \
        --set USE_BUILTIN_RIPGREP 0 \
        ${lib.optionalString stdenvNoCC.hostPlatform.isLinux ''
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [alsa-lib]} \
      ''}--prefix PATH : ${lib.makeBinPath (
        [procps ripgrep]
        ++ lib.optionals stdenvNoCC.hostPlatform.isLinux [bubblewrap socat]
      )}

      runHook postInstall
    '';

    meta = {
      description = "Anthropic Claude Code CLI";
      homepage = "https://github.com/anthropics/claude-code";
      license = lib.licenses.unfree;
      mainProgram = "claude";
      platforms = builtins.attrNames platformBySystem;
      sourceProvenance = with lib.sourceTypes; [binaryNativeCode];
    };
  }
