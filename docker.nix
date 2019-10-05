#!/usr/bin/env -S nix-build -o docker-image.tar
# Run this file with ./docker.nix.
# It creates a docker image archive called docker-image.tar.
# Import into docker with:
# docker load -i docker-image.tar
{ sources ? null }:
let
  pycryptpad-tools = import ./. { inherit sources; };
  deps = pycryptpad-tools.deps;

in deps.pkgs.dockerTools.buildLayeredImage {
  name = "pycryptpad-tools-cli";
  tag = "latest";

  config = {
    Entrypoint = "${pycryptpad-tools}/bin/cryptpad";
    Env = [
      "PATH=${deps.runPath}"
    ];
    Cmd = [ "--help" ];
  };
}

