#!/usr/bin/env bash

# this script is a patch to fix what looks like https://github.com/ipython-contrib/jupyter_contrib_nbextensions/issues/1529
# unpatched, the server shows warnings like these when loading a notebook:
#    [W 00:39:58.530 NotebookApp] Config option `template_path` not recognized by `ExporterCollapsibleHeadings`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:58.535 NotebookApp] Config option `template_path` not recognized by `ExporterCollapsibleHeadings`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:58.572 NotebookApp] Config option `template_path` not recognized by `TocExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:58.577 NotebookApp] Config option `template_path` not recognized by `TocExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:58.601 NotebookApp] Config option `template_path` not recognized by `LenvsHTMLExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:58.614 NotebookApp] Config option `template_path` not recognized by `LenvsHTMLExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:58.648 NotebookApp] Config option `template_path` not recognized by `LenvsTocHTMLExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:58.660 NotebookApp] Config option `template_path` not recognized by `LenvsTocHTMLExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:58.726 NotebookApp] Config option `template_path` not recognized by `LenvsLatexExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:58.729 NotebookApp] Config option `template_path` not recognized by `LenvsLatexExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:58.872 NotebookApp] Config option `template_path` not recognized by `LenvsSlidesExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:58.877 NotebookApp] Config option `template_path` not recognized by `LenvsSlidesExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:58.934 NotebookApp] Config option `template_path` not recognized by `ExporterCollapsibleHeadings`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:58.938 NotebookApp] Config option `template_path` not recognized by `ExporterCollapsibleHeadings`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:58.978 NotebookApp] Config option `template_path` not recognized by `TocExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:58.985 NotebookApp] Config option `template_path` not recognized by `TocExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:58.997 NotebookApp] Config option `template_path` not recognized by `LenvsHTMLExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:59.005 NotebookApp] Config option `template_path` not recognized by `LenvsHTMLExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:59.031 NotebookApp] Config option `template_path` not recognized by `LenvsTocHTMLExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:59.044 NotebookApp] Config option `template_path` not recognized by `LenvsTocHTMLExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:59.096 NotebookApp] Config option `template_path` not recognized by `LenvsLatexExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:59.103 NotebookApp] Config option `template_path` not recognized by `LenvsLatexExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:59.241 NotebookApp] Config option `template_path` not recognized by `LenvsSlidesExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
#    [W 00:39:59.246 NotebookApp] Config option `template_path` not recognized by `LenvsSlidesExporter`.  Did you mean one of: `extra_template_paths, template_name, template_paths`?
# 
# when using these versions:
# $ jupyter --version
# IPython          : 8.11.0
# ipykernel        : 6.21.2
# ipywidgets       : not installed
# jupyter_client   : 8.0.3
# jupyter_core     : 5.2.0
# jupyter_server   : 2.0.0
# jupyterlab       : not installed
# nbclient         : 0.5.13
# nbconvert        : 7.2.9
# nbformat         : 5.7.3
# notebook         : 6.2.0
# qtconsole        : not installed
# traitlets        : 5.9.0


DRY_RUN=0  # set to 1 to just print the changes
SITE_PACKAGES_DIR=$(python -c 'import site; print(site.getsitepackages()[0])')

patch-template-paths-with-backup() {
    _target_relpath=$1
    _target_file=$SITE_PACKAGES_DIR/$_target_relpath
    _backup_file=$_target_file.orig
    if [ -e $_backup_file ]; then
        echo "WARN: $_backup_file exists; assuming patch is already completed"
        return
    fi

    SED_STRING='s/\btemplate_path\b/template_paths/g'

    if [ $DRY_RUN -eq 1 ]; then
        cat $_target_file |
            sed $SED_STRING |
            diff -Naur $_target_file -
        read
    else
        set -x
        mv $_target_file $_backup_file
        set +x
        cat $_backup_file |
            sed $SED_STRING |
            cat > $_target_file
    fi
}

FILES_TO_CONVERT=(
    jupyter_contrib_nbextensions/config_scripts/highlight_html_cfg.py
    jupyter_contrib_nbextensions/config_scripts/highlight_latex_cfg.py
    jupyter_contrib_nbextensions/install.py
    jupyter_contrib_nbextensions/nbconvert_support/exporter_inliner.py
    jupyter_contrib_nbextensions/nbconvert_support/toc2.py
    jupyter_contrib_nbextensions/nbextensions/runtools/readme.md
    jupyter_core/tests/dotipython_empty/profile_default/ipython_nbconvert_config.py
    latex_envs/latex_envs.py
);

for file_to_convert in ${FILES_TO_CONVERT[@]}; do
    echo $file_to_convert
    patch-template-paths-with-backup $file_to_convert
done
