{
  stdenv,
  fetchzip,
  autoPatchelfHook
}:

let
  url = "https://github.com/CDSoft/ypp/releases/download/1.5/ypp-1.5-linux-x86_64.tar.gz";
  hash = "sha256-PeDFOXjQh++oqClcnoCFvla7sAjiPomwm0h2DKkOkIk=";
  version = "1.5";
in

stdenv.mkDerivation {
  pname = "ypp";
  inherit version;
  src = fetchzip { inherit url hash; stripRoot = false; };

  nativeBuildInputs = [
    autoPatchelfHook
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    install */bin/ypp "$out/bin/ypp"
    runHook postInstall
  '';
}
