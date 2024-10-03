{ stdenv }:
stdenv.mkDerivation rec {
  name = "keycloak_agatha_theme";
  version = "1.0";

  src = ./keycloak_agatha_theme;

  nativeBuildInputs = [ ];
  buildInputs = [ ];

  installPhase = ''
    mkdir -p $out
    cp -a login $out
  '';
}
