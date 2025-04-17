{
  stdenv,
  fetchzip,
  autoPatchelfHook
}:

let
  url = "https://github.com/CDSoft/ypp/releases/download/1.7.3/ypp-1.7.3-linux-x86_64.tar.gz";
  hash = "sha256-HCPGmfcKpyqcE5B1ExrQkcX7J1S+eNKwy23XnuYOr/0=";
  version = "1.7.3";
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
