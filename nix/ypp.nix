{
  stdenv,
  fetchzip,
  autoPatchelfHook
}:

let
  url = "https://cdelord.fr/pub/luax-ssl-linux-x86_64.tar.xz";
  hash = "sha256-DSTgoL12v8Rox/cTz1ksUNp6I5JWQTg3KV8mWU6kPIY=";
  lastUpdate = "2024-12-14";
in

stdenv.mkDerivation {
  pname = "ypp";
  version = lastUpdate;
  src = fetchzip { inherit url hash; stripRoot = false; };

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
