{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  zlib,
  fontconfig,
  freetype,
  libGL,
  alsa-lib,
  libx11,
  libxext,
  libxi,
  libxrender,
  libxtst,
  libxrandr,
  libxcursor,
  libxcb,
  giflib,
  libxcrypt-legacy,
  wayland,
  libxkbcommon,
}: let
  # EAP builds expire ~30 days after their release date and then refuse to
  # start ("This build of kotlin-server has expired"). GitHub releases and the
  # JetBrains release feed both lag behind the CDN, so when the current build
  # dies check the VS Code Marketplace build number in
  # https://github.com/Kotlin/kotlin-lsp/issues and fetch it straight from the
  # CDN path below -- the tarball is published there before it is announced.
  version = "263.4421.0";

  sources = {
    x86_64-linux = {
      url = "https://download-cdn.jetbrains.com/language-server/kotlin-server/${version}/kotlin-server-${version}.tar.gz";
      hash = "sha256-0dq073s5qI93zPaNXloWXJ88Xg+bG7mSPmJaVL08Zz8=";
    };
    aarch64-linux = {
      url = "https://download-cdn.jetbrains.com/language-server/kotlin-server/${version}/kotlin-server-${version}-aarch64.tar.gz";
      # Fill in with `nix-prefetch-url` if this machine ever runs aarch64.
      hash = lib.fakeHash;
    };
  };

  source =
    sources.${stdenv.hostPlatform.system}
    or (throw "kotlin-lsp: unsupported system ${stdenv.hostPlatform.system}");
in
  stdenv.mkDerivation {
    pname = "kotlin-lsp";
    inherit version;

    src = fetchurl {inherit (source) url hash;};

    nativeBuildInputs = [autoPatchelfHook makeWrapper];

    # The tarball ships the IntelliJ platform plus a bundled JetBrains Runtime;
    # autoPatchelf needs the JBR's native dependencies even though the server
    # runs headless.
    buildInputs = [
      stdenv.cc.cc.lib
      zlib
      fontconfig
      freetype
      libGL
      alsa-lib
      giflib
      libxcrypt-legacy
      wayland
      libxkbcommon
      libx11
      libxext
      libxi
      libxrender
      libxtst
      libxrandr
      libxcursor
      libxcb
    ];

    # Prebuilt binaries: nothing to strip or rebuild, and the JBR ships jars
    # whose timestamps matter for the platform's own integrity checks.
    dontStrip = true;
    dontBuild = true;
    dontConfigure = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/share/kotlin-lsp" "$out/bin"
      cp -a . "$out/share/kotlin-lsp"

      chmod +x "$out/share/kotlin-lsp/bin/intellij-server"

      # The launcher resolves the IDE home from its own path, so wrap rather
      # than symlink. JAVA_HOME is unset so the bundled JBR wins over any JDK
      # the user happens to have exported (the server needs Java >= 25).
      makeWrapper "$out/share/kotlin-lsp/bin/intellij-server" "$out/bin/kotlin-lsp" \
        --unset JAVA_HOME \
        --unset JDK_HOME

      runHook postInstall
    '';

    meta = {
      description = "Official Kotlin language server by JetBrains, based on IntelliJ IDEA";
      homepage = "https://github.com/Kotlin/kotlin-lsp";
      license = lib.licenses.asl20;
      platforms = lib.attrNames sources;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      mainProgram = "kotlin-lsp";
    };
  }
