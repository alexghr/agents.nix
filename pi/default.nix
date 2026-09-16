{
  buildNpmPackage,
  lib,
  makeWrapper,
  nodejs,
}: let
  packageJson = builtins.fromJSON (builtins.readFile ./package.json);
  version = packageJson.dependencies."@earendil-works/pi-coding-agent";
in
  buildNpmPackage {
    pname = "pi-coding-agent";
    inherit version;

    src = ./.;
    npmDepsHash = lib.fileContents ./npm-deps-hash;
    npmDepsFetcherVersion = 2;
    dontNpmBuild = true;

    nativeBuildInputs = [makeWrapper];

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/lib/pi" "$out/bin"
      cp -R node_modules "$out/lib/pi/"
      makeWrapper ${lib.getExe nodejs} "$out/bin/pi" \
        --add-flags "$out/lib/pi/node_modules/@earendil-works/pi-coding-agent/dist/bundle/cli.js" \
        --prefix PATH : ${lib.makeBinPath [nodejs]}

      runHook postInstall
    '';

    meta = {
      description = "Minimal terminal coding harness";
      homepage = "https://pi.dev";
      license = lib.licenses.mit;
      mainProgram = "pi";
    };
  }
