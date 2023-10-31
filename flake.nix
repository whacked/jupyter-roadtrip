{
  nixConfig.bash-prompt = ''\033[1;32m\[[nix-develop:\[\033[36m\]\w\[\033[32m\]]$\033[0m '';

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/23.05-pre";
    flake-utils.url = "github:numtide/flake-utils";
    whacked-setup = {
      url = "github:whacked/setup/58bdbff2eec48980b010048032382bed3a152e7e";
      flake = false;
    };
  };
  outputs = { self, nixpkgs, flake-utils, whacked-setup }:
    flake-utils.lib.eachDefaultSystem
    (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      # pkgs.currentSystem = system;
      whacked-helpers = import (whacked-setup + /nix/flake-helpers.nix) { inherit pkgs; };
      # whacked-helpers = import ~/setup/nix/flake-helpers.nix { inherit pkgs; };
    in {
      devShell = whacked-helpers.mkShell {
        flakeFile = __curPos.file;  # used to forward current file to echo-shortcuts
        includeScripts = [
          # e.g. for node shortcuts
          # (whacked-setup + /bash/node_shortcuts.sh)
        ];
      } {
        # buildInputs = common.getBuildInputs pkgs;
        buildInputs = [
          pkgs.bashInteractive
          pkgs.gnumake
          pkgs.pastel

          pkgs.python3Full
          pkgs.python3Packages.autopep8
          pkgs.python3Packages.toolz
          pkgs.python3Packages.matplotlib
          pkgs.python3Packages.numpy
          pkgs.python3Packages.pandas
          pkgs.python3Packages.mplfinance
          pkgs.python3Packages.seaborn
          pkgs.python3Packages.more-itertools

          pkgs.graphviz
          pkgs.nodejs
        ] ++ (
          if pkgs.stdenv.isLinux then [
            pkgs.quarto
          ] else [
          ]
        );  # join lists with ++

        shellHook = (
          if pkgs.stdenv.isDarwin then ''
          ### PREFLIGHT
          if ! command -v quarto &> /dev/null; then
            pastel paint red "program 'quarto' not found in the path. nbdev requires it to work"
            echo -n "you can obtain it manually from "
            pastel paint yellow https://quarto.org/docs/get-started
            exit
          fi
          '' else ''
          '') + ''
          ### SETUP
          export VIRTUAL_ENV=''${VIRTUAL_ENV-$PWD/venv}
          # FIX for ImportError: libstdc++.so.6: cannot open shared object file: No such file or directory
          # but note that gcc may be a costly import
          # export LD_LIBRARY_PATH=${pkgs.gcc-unwrapped.lib}/lib:$LD_LIBRARY_PATH
          export LD_LIBRARY_PATH=${pkgs.zlib}/lib:${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH
          export JUPYTER_CONFIG_DIR=''${JUPYTER_CONFIG_DIR-$PWD/.jupyter}
          if [ ! -e $JUPYTER_CONFIG_DIR ]; then
            mkdir $JUPYTER_CONFIG_DIR
          fi
          setup-jupyter-extensions() {
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
                jupyter nbextension enable $ext --user
            done
            pip install git+https://github.com/whacked/Jupyter-multi_outputs
            jupyter nbextension install --py lc_multi_outputs --user
            jupyter nbextension enable --py lc_multi_outputs --user

            bash ./scripts/environment-management/patch-jupyter-venv.sh

            pip install bash_kernel==0.9.0
            python -m bash_kernel.install
          }
          setup-venv() {  # install all expected virutalenv packages
            # see note at https://stackoverflow.com/a/65599505
            # on nb extensions (in)compatibility.
            # below versions are from trial and error
            pip install \
              twine==4.0.2 \
              notebook==6.2.0 \
              jupyter_server==2.3.0 \
              jupyter_core==5.2.0 \
              nbconvert==7.2.9 \
              nbformat==5.7.3 \
              nbdev==2.3.12 \
              jupytext==1.14.5 \
              jupyter_contrib_nbextensions==0.5.1 \
              jupyter_nbextensions_configurator
            jupyter contrib nbextension install --user
            setup-jupyter-extensions
          }
          ensure-venv setup-venv
        '' + ''
          ### SHORTCUTS
          alias start-notebook="jupyter notebook"
        '';  # join strings with +
      };
    }
  );
}
