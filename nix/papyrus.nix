{
  stdenv,
  bash
}:

stdenv.mkDerivation {
  pname = "papyrus";
  version = "1.0.0";
  src = ../lib;

  buildInputs = [
    bash
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/bin"
    install papyrus.sh "$out/bin/papyrus.sh"
    runHook postInstall
  '';
}
