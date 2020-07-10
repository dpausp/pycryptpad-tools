# Build Python package.
# Can be installed in the current user profile with:
# nix-env -if .
{ sources ? null }:
let
  deps = import ./nix/deps.nix { inherit sources; };
  inherit (deps) pkgs mkPoetryApplication externalRuntimeDeps;
  inherit (deps.pyProject) version;

in mkPoetryApplication {
  projectDir = ./.;
  passthru = {
    inherit deps version;
  };

  propagatedBuildInputs = externalRuntimeDeps;
}
