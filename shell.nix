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
    pkgs.python310Packages.autopep8
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
      sha256 = "0pj6ml8hzxn6hzmxhghnq09cs7s5ibjq7hd649j198la7jx4vin8";
    })
  ];

  shellHook = ''
    ### SETUP
    export VIRTUAL_ENV=''${VIRTUAL_ENV-$PWD/venv}
    # FIX for ImportError: libstdc++.so.6: cannot open shared object file: No such file or directory
    # but note that gcc may be a costly import
    export LD_LIBRARY_PATH=${pkgs.gcc-unwrapped.lib}/lib:$LD_LIBRARY_PATH
    setup-venv() {  # install all expected virutalenv packages
      # see note at https://stackoverflow.com/a/65599505
      # on nb extensions (in)compatibility.
      # below versions are from trial and error
      pip install \
        notebook==6.2.0 \
        jupyter_server==2.0.0 \
        jupyter_core==5.2.0 \
        nbconvert==7.2.9 \
        nbformat==5.7.3 \
        nbdev==2.3.12 \
        jupyter_contrib_nbextensions==0.5.1 \
        jupyter_nbextensions_configurator
      jupyter contrib nbextension install --user
      ENABLE_BUNDLED_EXTENSIONS=(
          code_prettify/autopep8
          codefolding/main
          collapsible_headings/main
          contrib_nbextensions_help_item/main
          datestamper/main
          execute_time/ExecuteTime
          freeze/main
          scratchpad/main
          toc2/main
          toggle_all_line_numbers/main
          varInspector/main
      );
      for ext in ''${ENABLE_BUNDLED_EXTENSIONS[@]}; do
          jupyter nbextension enable $ext
      done
      pip install git+https://github.com/whacked/Jupyter-multi_outputs
      jupyter nbextension install --py lc_multi_outputs --user
      jupyter nbextension enable --py lc_multi_outputs --user
    }
    ensure-venv setup-venv
  '' + ''
    ### SHORTCUTS
    alias start-notebook="jupyter notebook"
  '' + ''
    echo-shortcuts ${__curPos.file}
  '';  # join strings with +
}
