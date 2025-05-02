{
  description = "A modular document processing tool that converts Markdown to other formats with `ypp` and `pandoc`.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      allSystems = [
        "x86_64-linux"
      ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs allSystems (
          system:
          f {
            pkgs = nixpkgs.legacyPackages.${system};
          }
        );
    in
    {
      packages = forAllSystems (
        { pkgs }:
        let
          ypp =
            let
              version = "1.7.3";
              baseUrl = "https://github.com/CDSoft/ypp/releases/download/${version}";
              sources = {
                "x86_64-linux" = pkgs.fetchzip {
                  url = "${baseUrl}/ypp-${version}-linux-x86_64.tar.gz";
                  hash = "sha256-HCPGmfcKpyqcE5B1ExrQkcX7J1S+eNKwy23XnuYOr/0=";
                };
              };
            in
            pkgs.stdenv.mkDerivation {
              pname = "ypp";
              inherit version;
              src = sources.${pkgs.system};

              nativeBuildInputs = [
                pkgs.autoPatchelfHook
              ];

              dontBuild = true;
              installPhase = ''
                runHook preInstall
                install -D -- */bin/ypp "$out/bin/ypp"
                runHook postInstall
              '';
            };

          papyrus = pkgs.stdenv.mkDerivation {
            name = "papyrus";
            src = ./.;

            nativeBuildInputs = [
              pkgs.makeWrapper
            ];

            dontBuild = true;
            installPhase =
              let
                binPath = pkgs.lib.makeBinPath (
                  (with pkgs; [
                    pandoc_3_6
                    coreutils
                  ])
                  ++ [
                    ypp
                  ]
                );
              in
              ''
                runHook preInstall

                mkdir -p -- "$out/share/papyrus"
                cp -r -- modules "$out/share/papyrus/modules"
                install -D -- papyrus.sh "$out/bin/papyrus.sh"

                wrapProgram \
                  "$out/bin/papyrus.sh" \
                  --prefix PATH : "${binPath}" \
                  --suffix PAPYRUS_MODULES : "$out/share/papyrus/modules"

                runHook postInstall
              '';
          };
        in
        {
          inherit papyrus;
          default = papyrus;
        }
      );

      apps = forAllSystems (
        { pkgs }:
        let
          papyrus = {
            type = "app";
            program = "${self.packages.${pkgs.system}.papyrus}/bin/papyrus.sh";
          };
        in
        {
          inherit papyrus;
          default = papyrus;
        }
      );

      formatter = forAllSystems ({ pkgs }: pkgs.nixfmt-rfc-style);

      devShells = forAllSystems (
        { pkgs }:
        {
          default = pkgs.mkShellNoCC {
            packages =
              (with pkgs; [
                bashInteractive
                shellcheck
                nixd
                nixfmt-rfc-style
              ])
              ++ [
                self.packages.${pkgs.system}.papyrus
                pkgs.haskellPackages.pandoc-crossref
                pkgs.imagemagickBig
                pkgs.mermaid-cli
              ];

            shellHook = ''
              export -- PAPYRUS_MODULES="$PWD/modules''\${PAPYRUS_MODULES:+:''\${PAPYRUS_MODULES:-}}"
            '';
          };
        }
      );
    };
}
