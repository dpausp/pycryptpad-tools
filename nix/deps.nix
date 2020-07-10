{ sources ? null }:
let
  sources_ = if (sources == null) then import ./sources.nix else sources;
  pkgs = import sources_.nixpkgs { };
  niv = (import sources_.niv { }).niv;
  eliotPkgs = (import ./eliot.nix { inherit pkgs; }).packages;
  pdbpp = (import ./pdbpp.nix { inherit pkgs; }).packages.pdbpp;
  inherit ((import "${sources_.poetry2nix}/overlay.nix") pkgs pkgs) poetry2nix poetry;
  python = pkgs.python38;

  poetryWrapper = with python.pkgs; pkgs.writeScriptBin "poetry" ''
    export PYTHONPATH=
    unset SOURCE_DATE_EPOCH
    ${poetry}/bin/poetry "$@"
  '';

in rec {
  inherit pkgs;
  inherit (pkgs) lib glibcLocales;
  inherit (poetry2nix) mkPoetryApplication;

  # Essential Python libs for the application
  libs =  with python.pkgs; [
    click
    selenium
    eliotPkgs.eliot
  ];

  # Can be imported in Python code or run directly as debug tools
  debugLibsAndTools = with python.pkgs; [
    pdbpp
    ipython
  ];

  # Python interpreter that can run the application
  pythonEnv = python.buildEnv.override {
    extraLibs = libs ++ debugLibsAndTools;
    ignoreCollisions = true;
  };

  # Non-Python dependencies needed for running the application
  externalRuntimeDeps = with pkgs; [
    chromium
    chromedriver
  ];

  # Code style and security tools
  linters = with python.pkgs; [
    bandit
    pylama
    pylint
    yapf
  ];

  # Various tools for log files, deps management, running scripts and so on
  shellTools = with pkgs; [
    eliotPkgs.eliot-tree
    entr
    jq
    poetryWrapper
    niv
    zsh
  ];

  # Needed for a development nix shell
  shellInputs =
    [ pythonEnv ] ++
    linters ++
    shellTools ++
    externalRuntimeDeps ++
    debugLibsAndTools;

  shellPath = lib.makeBinPath shellInputs;

  runPath = lib.makeBinPath externalRuntimeDeps;
}
