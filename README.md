# jupyter roadtrip

an opinionated, [nbdev](https://nbdev.fast.ai/)-enabled, batteries-included jupyter environment to faciliate notebook usage, maintenance, and interoperation

this has been tested on ubuntu linux 22.04 and macOS Monterey running Nix 2.3.x

## latest "works for me" version

these versions should correspond to the hand-locked versions specified in the shell.nix environment

```
$ jupyter --version
Selected Jupyter core packages...
IPython          : 8.11.0
ipykernel        : 6.21.2
ipywidgets       : not installed
jupyter_client   : 8.0.3
jupyter_core     : 5.2.0
jupyter_server   : 2.3.0
jupyterlab       : not installed
nbclient         : 0.7.2
nbconvert        : 7.2.9
nbformat         : 5.7.3
notebook         : 6.2.0
qtconsole        : not installed
traitlets        : 5.9.0
```

# prerequisites

a working [Nix package manager environment](https://nixos.org/download.html)

**mac users** must [manually install quarto](https://quarto.org/docs/get-started/) for now, because the `quarto` package is marked as unsupported in the nix repository.

# usage

enter the environment with `nix-shell`.

once in the shell, you should be able to run `jupyter notebook` and any of the `nbdev_*` functions

# details

This environment installs all packages necessary to run a working `nbdev` notebook environment, including the [2 recommended extensions](https://nbdev.fast.ai/tutorials/tutorial.html#install-collapsible-headings-and-toc2) (Collapsible headings and TOC2) listed in the [tutorial](https://nbdev.fast.ai/tutorials/tutorial.html).

In total, this install enables these useful extensions:

- [bash kernel for IPython](https://github.com/takluyver/bash_kernel)
- [jupytext](https://github.com/mwouts/jupytext)
- [LC multi outputs (whacked's fork)](https://github.com/whacked/Jupyter-multi_outputs/): keeps repeated execution of the same cell into separate, timestamped tabs
- nbextensions manager tab inthe jupyter main view
- Collapsible Headings: collapse markdown sections
- Codefolding: fold code in cells
- ExecuteTime: shows last executed time + execution duration
- toggle line numbers in cells
- Freeze: mark cells read-only / frozen
- Scratchpad: throw-away / temporary code execution area
- Autopep8: auto-format / clean up cell code using pep8 (note this extension causes an annoying popup to appear when opening bash kernel notebooks)
- datestamper: install current datestamp
- Table of Contents (2): shows navigation panel to jump to markdown section headings
- Variable Inspector

