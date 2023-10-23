{ lib, pkgs, nodejsPackage }:
let
  # Special case: nodejsPackage is inherited to allow one definition of the Node.js version.
  buildNpmPackage = pkgs.buildNpmPackage.override { nodejs = nodejsPackage; };

  # We need to specify exact paths to various binaries used by Prisma.
  # This.. is not ideal! It's mirrored to the systemd service within `./nix/service.nix`.
  #
  # See also: https://github.com/prisma/prisma/issues/3026#issuecomment-927258138
  prismaEnvironment = ''
    # TODO: When Turtle is migrated to Prisma 5.x, rename to SCHEMA_ENGINE.
    export PRISMA_MIGRATION_ENGINE_BINARY="${pkgs.prisma-engines}/bin/schema-engine"
    export PRISMA_QUERY_ENGINE_BINARY="${pkgs.prisma-engines}/bin/query-engine"
    export PRISMA_QUERY_ENGINE_LIBRARY="${pkgs.prisma-engines}/lib/libquery_engine.node"
  '';
in
buildNpmPackage {
  pname = "turtle";
  version = "1.0.0";

  # We rely on Nix to manage our dependencies as specified.
  npmDepsHash = "sha256-Hj/fwvdUxN7Ljb4BA7QqKZfF2AYaD9imVl8xi56Rmfc=";
  src = ../.;

  # Prisma needs to be fully pulled in.
  buildInputs = [
    pkgs.nodePackages.prisma
  ];

  # We have to generate Prisma prior to building.
  preBuild = ''
    ${prismaEnvironment}
    npm run prisma-generate
  '';

  meta = with lib; {
    description = "The Turtle Discord bot";
    homepage = "https://github.com/FoxNetworking/turtle";
    license = licenses.isc;
    maintainers = with maintainers; [ spotlightishere ];
  };
}
