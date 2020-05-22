{ sources ? null }:
let
  sources_ = if (sources == null) then import ./sources.nix else sources;
  pkgs = import sources_.nixpkgs { };
  niv = (import sources_.niv { }).niv;
  bandit = (import ./bandit.nix { inherit pkgs; }).packages.bandit;
  eliotPkgs = (import ./eliot.nix { inherit pkgs; }).packages;
  lib = pkgs.lib;
  pythonVersion = "37";
  pythonPackages = pkgs."python${pythonVersion}Packages";
  python_ = pkgs."python${pythonVersion}";

  pipWrapper = with pythonPackages; with python; pkgs.writeScriptBin "pip" ''
    export PYTHONPATH=${setuptools}/${sitePackages}:${wheel}/${sitePackages}
    unset SOURCE_DATE_EPOCH
    ${pip}/bin/pip "$@"
  '';

in rec {
  inherit pkgs;

  # Essential Python libs for the application
  libs =  with pythonPackages; [
    click
    selenium
    eliotPkgs.eliot
  ];

  # Can be imported in Python code or run directly as debug tools
  debugLibsAndTools = with pythonPackages; [
    ipdb
    ipython
  ];

  # Python interpreter that can run the application
  python = python_.buildEnv.override {
    extraLibs = libs ++ debugLibsAndTools;
  };

  # Non-Python dependencies needed for running the application
  externalRuntimeDeps = with pkgs; [
    chromium
    chromedriver
  ];

  # Code style and security tools
  linters = with pythonPackages; [
    bandit
    pylama
    pylint
    autopep8
  ];

  # Various tools for log files, deps management, running scripts and so on
  shellTools = with pkgs; [
    eliotPkgs.eliot-tree
    entr
    jq
    pipWrapper
    pythonPackages.twine
    niv
    zsh
  ];

  # Needed for a development nix shell
  shellInputs =
    [ python ] ++
    linters ++
    shellTools ++
    externalRuntimeDeps ++
    debugLibsAndTools;

  shellPath = lib.makeBinPath shellInputs;

  runPath = lib.makeBinPath externalRuntimeDeps;
}
