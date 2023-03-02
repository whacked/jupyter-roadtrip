{ pkgs ? import <nixpkgs> {} }:
let
  helpers = import (
    builtins.fetchurl {
      url = "https://raw.githubusercontent.com/whacked/setup/master/nix/helpers.nix";
      sha256 = "1vby29hnzhannl75kjc55169pbdglfxvsmqszj7krzik60lhgyfq";
    });
in helpers.mkShell [
] {
  buildInputs = [
    pkgs.gnumake

    pkgs.python310Full
    pkgs.python310Packages.jupyter
    pkgs.python310Packages.toolz
    pkgs.python310Packages.matplotlib
    pkgs.python310Packages.numpy
    pkgs.python310Packages.pandas
    pkgs.python310Packages.mplfinance
    pkgs.python310Packages.seaborn
    pkgs.python310Packages.more-itertools

    pkgs.graphviz
    pkgs.nodejs
    pkgs.quarto
  ];  # join lists with ++

  nativeBuildInputs = [
    (builtins.fetchurl {
      url = "https://raw.githubusercontent.com/whacked/setup/master/bash/nix_shortcuts.sh";
      sha256 = "04qfbcs9ar1pp616bqkpi2vc5jhjxlgk53n26akal97hfriz95rl";
    })
  ];

  shellHook = ''
    export VIRTUAL_ENV=''${VIRTUAL_ENV-$PWD/venv}
    setup-venv() {
      pip install \
        nbdev==2.3.12
    }
    ensure-venv setup-venv
  '' + ''
    echo-shortcuts ${__curPos.file}
  '';  # join strings with +
}
