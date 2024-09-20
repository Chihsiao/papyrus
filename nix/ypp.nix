{
  stdenv,
  fetchzip,
  autoPatchelfHook
}:

let
  url = "https://cdelord.fr/hey/ypp-linux-x86_64.tar.xz";
  hash = "sha256-CngKUXs3i/ca9D88LYyGGguW+JZ4WzDq0WDvcAoIp9U=";
  lastUpdate = "2024-04-12";
in

stdenv.mkDerivation {
  pname = "ypp";
  version = lastUpdate;
  src = fetchzip { inherit url hash; };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    install bin/ypp "$out/bin/ypp"
    runHook postInstall
  '';
}
