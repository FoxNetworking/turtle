{ buildNpmPackage, lib, pkgs, nodejsPackage }:
# Special case: nodejsPackage is inherited to allow one definition of the Node.js version.
buildNpmPackage.override { nodejs = nodejsPackage; } {
  pname = "turtle";
  version = "1.0.0";

  # We rely on Nix to manage our dependencies as specified.
  npmDepsHash = "sha256-2kIJUjRder3B4WSGqJG/FjXJVlqZ0UQ//lN3LzdMJZY=";
  src = ../.;

  # We have to generate Prisma prior to building.
  # TODO(spotlightishere): Why?
  preBuild = ''
    ${pkgs.nodePackages.prisma}/bin/prisma generate
  '';

  meta = with lib; {
    description = "The Turtle Discord bot";
    homepage = "https://github.com/FoxNetworking/turtle";
    license = licenses.isc;
    maintainers = with maintainers; [ spotlightishere ];
  };
}