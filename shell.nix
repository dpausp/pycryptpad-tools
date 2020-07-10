{ sources ? null }:
let
  deps = import ./nix/deps.nix { inherit sources; };
  inherit (deps) pkgs;
  inherit (pkgs) lib stdenv;
  caBundle = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";

in pkgs.mkShell {
  name = "pycryptpad-tools";
  buildInputs = deps.shellInputs;
  # A pure nix shell breaks SSL for git and nix tools which is fixed by setting the path to the certificate bundle.
  shellHook = ''
    export NIX_SSL_CERT_FILE=${caBundle}
    export PATH=${deps.shellPath}:$PATH
    export PYTHONPATH=./src
    export SSL_CERT_FILE=${caBundle}
  '' +
  lib.optionalString (pkgs.stdenv.hostPlatform.libc == "glibc") ''
    export LOCALE_ARCHIVE=${deps.glibcLocales}/lib/locale/locale-archive
  '';
}
