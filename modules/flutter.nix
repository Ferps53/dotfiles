# Flutter no NixOS: o SDK fica em /nix/store (somente-leitura), mas o
# template novo do Flutter (settings.gradle.kts com includeBuild +
# dev.flutter.flutter-plugin-loader) exige que
# $FLUTTER_ROOT/packages/flutter_tools/gradle seja GRAVAVEL. Resultado:
#   "Configuring project ':' without an existing directory is not allowed"
#
# Solucao geral (sem shell.nix/direnv por projeto):
#   - Cria um espelho gravavel do SDK em ~/.local/share/flutter-writable-sdk:
#     tudo e symlink pro store, MENOS packages/flutter_tools/gradle, que e
#     uma copia real com permissao de escrita.
#   - Exporta FLUTTER_ROOT apontando pro espelho. O wrapper do nixpkgs
#     respeita FLUTTER_ROOT ja definido, entao o flutter grava esse caminho
#     gravavel em local.properties de qualquer projeto, automaticamente.
{pkgs, ...}: let
  realFlutter = pkgs.flutter;
  mirrorRel = ".local/share/flutter-writable-sdk";

  # (Re)constroi o espelho quando o caminho do store muda (update/GC).
  syncSdk = pkgs.writeShellScriptBin "flutter-writable-sdk-sync" ''
    set -eu
    SRC="${realFlutter}"
    MIRROR="''${XDG_DATA_HOME:-$HOME/.local/share}/flutter-writable-sdk"
    STAMP="$MIRROR/.nix-src"

    if [ "$(cat "$STAMP" 2>/dev/null || true)" = "$SRC" ]; then
      exit 0
    fi

    rm -rf "$MIRROR"
    mkdir -p "$MIRROR/packages/flutter_tools"

    # topo do SDK: symlink tudo menos 'packages'
    for e in "$SRC"/* "$SRC"/.[!.]*; do
      [ -e "$e" ] || continue
      b="$(basename "$e")"
      [ "$b" = packages ] && continue
      ln -s "$e" "$MIRROR/$b"
    done

    # packages/*: symlink tudo menos 'flutter_tools'
    for e in "$SRC"/packages/*; do
      b="$(basename "$e")"
      [ "$b" = flutter_tools ] && continue
      ln -s "$e" "$MIRROR/packages/$b"
    done

    # flutter_tools/*: symlink tudo menos 'gradle'
    for e in "$SRC"/packages/flutter_tools/*; do
      b="$(basename "$e")"
      [ "$b" = gradle ] && continue
      ln -s "$e" "$MIRROR/packages/flutter_tools/$b"
    done

    # gradle: copia real e gravavel (o unico dir que o Gradle escreve)
    cp -rL "$SRC/packages/flutter_tools/gradle" "$MIRROR/packages/flutter_tools/gradle"
    chmod -R u+w "$MIRROR/packages/flutter_tools/gradle"

    printf '%s' "$SRC" > "$STAMP"
  '';

  mkWrapper = name:
    pkgs.writeShellScriptBin name ''
      ${syncSdk}/bin/flutter-writable-sdk-sync || true
      export FLUTTER_ROOT="''${XDG_DATA_HOME:-$HOME/.local/share}/flutter-writable-sdk"
      exec ${realFlutter}/bin/${name} "$@"
    '';

  flutterWrapped = mkWrapper "flutter";
  dartWrapped = mkWrapper "dart";
in {
  # Wrappers antes do flutter real; NAO adicionar pkgs.flutter direto.
  environment.systemPackages = [
    flutterWrapped
    dartWrapped
    syncSdk
  ];

  # GUI (Android Studio lancado pelo desktop) tambem enxerga o SDK gravavel.
  environment.sessionVariables.FLUTTER_ROOT = "$HOME/${mirrorRel}";

  # Garante o espelho pronto no login, antes de abrir a IDE.
  systemd.user.services.flutter-writable-sdk = {
    description = "Constroi espelho gravavel do Flutter SDK (store e read-only)";
    wantedBy = ["default.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${syncSdk}/bin/flutter-writable-sdk-sync";
    };
  };
}
