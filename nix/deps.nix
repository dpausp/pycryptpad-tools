{ sources ? null }:
let
  sources_ = if (sources == null) then import ./sources.nix else sources;
  pkgs = import sources_.nixpkgs { };
  niv = (import sources_.niv { }).niv;
  bandit = (import ./bandit.nix { inherit pkgs; }).packages.bandit;
  eliotPkgs = (import ./eliot.nix { inherit pkgs; }).packages;

in rec {
  inherit pkgs;
  inherit (pkgs) lib;

  # Essential Python libs for the application
  libs = (with pkgs.python37Packages; [
      click
      selenium
    ]) ++ [
      eliotPkgs.eliot
    ];

  # Can be imported in Python code or run directly as debug tools
  debugLibsAndTools = with pkgs.python37Packages; [
    ipdb
    ipython
  ];

  # Python interpreter that can run the application
  python = pkgs.python37.buildEnv.override {
    extraLibs = libs ++ debugLibsAndTools;
    ignoreCollisions = true;
  };

  # Non-Python dependencies needed for running the application
  externalRuntimeDeps = with pkgs; [
    chromium
    chromedriver
  ];

  # Code style and security tools
  linters = with pkgs.python37Packages; [
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
