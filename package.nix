{ lib
, stdenv
, rustPlatform
, pkg-config
, makeWrapper
, wayland
, libxkbcommon
, libGL
, vulkan-loader
, fontconfig
, freetype
, libx11
, libxcursor
, libxi
, libxcb
, libxkbfile
, vectorcraft-src
}:

let
  sourceManifest = builtins.fromTOML (builtins.readFile (vectorcraft-src + "/Cargo.toml"));
  runtimeLibraries = [
    wayland
    libxkbcommon
    libGL
    vulkan-loader
    fontconfig
    freetype
    libx11
    libxcursor
    libxi
    libxcb
    libxkbfile
  ];
in
rustPlatform.buildRustPackage {
  pname = "vectorcraft";
  version = sourceManifest.workspace.package.version;
  src = vectorcraft-src;

  cargoHash = "sha256-i3af3PzqPpcm1tb38YjfYHC8OiTwwfRmeFkLblXZ1i8=";
  cargoBuildFlags = [ "-p" "vectorcraft" "--bin" "vectorcraft" ];

  postPatch = ''
    # These optional egui crates are absent from the pinned upstream commit.
    # Cargo ignores the unused patches, but vendored offline builds require
    # every patched package to exist in its source tree.
    sed -i \
      -e '/^egui_demo_lib = /d' \
      -e '/^egui_inspection = /d' \
      -e '/^egui_system_font_provider = /d' \
      Cargo.toml
  '';

  nativeBuildInputs = [ pkg-config makeWrapper ];

  # The upstream project runs its full Rust test suite in CI. This derivation
  # builds the desktop binary for the local package/cache; it is not that CI.
  doCheck = false;

  installPhase = ''
    runHook preInstall

    install -Dm755 target/${stdenv.hostPlatform.rust.rustcTarget}/release/vectorcraft \
      $out/bin/vectorcraft
    install -Dm644 packaging/linux/ai.storyteller.vectorcraft.desktop \
      $out/share/applications/ai.storyteller.vectorcraft.desktop
    install -Dm644 packaging/linux/ai.storyteller.vectorcraft.mime.xml \
      $out/share/mime/packages/ai.storyteller.vectorcraft.xml
    cp -R assets/app-icon/hicolor $out/share/icons/

    wrapProgram $out/bin/vectorcraft \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath runtimeLibraries}"

    runHook postInstall
  '';

  meta = {
    description = "Open-source vector illustration app";
    homepage = "https://github.com/storytold/vectorcraft";
    license = with lib.licenses; [ mit asl20 ];
    mainProgram = "vectorcraft";
    platforms = [ "x86_64-linux" ];
  };
}
