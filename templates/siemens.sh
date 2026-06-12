#!/usr/bin/env bash
# siemens.sh — Siemens EDA tool environment setup
#
# Copy to ~/bin/siemens.sh and adapt the variables below to your site layout.
# Source this file before launching Catapult (the Makefile does it automatically
# for the catapult-gui and catapult-shell targets).

# ----------

export CATAPULT_VER=2026.2

# Root path where Catapult releases are installed
export CATAPULT_PATH=/mnt/local/gdg/tools/cad/siemens/catapult/${CATAPULT_VER}

# Uncomment and set if using Questa for RTL simulation
#export QUESTASIM_VER=2025.2_2
#export MODELTECH=/path/to/questa/${QUESTASIM_VER}/questasim/bin

# ----------

export MGC_HOME=${CATAPULT_PATH}/Mgc_home
export CATAPULT_HOME=${MGC_HOME}
export SYSTEMC=${MGC_HOME}/shared
export SYSTEMC_HOME=${SYSTEMC}
export LIBDIR="-L${MGC_HOME}/shared/lib ${LIBDIR:-}"
export LD_LIBRARY_PATH=${MGC_HOME}/lib:${MGC_HOME}/shared/lib:${LD_LIBRARY_PATH:-}
export PATH=${MGC_HOME}/bin${MODELTECH:+:${MODELTECH}}:${PATH}

# Show active version in the prompt. When Starship is active it picks up
# CATAPULT_VER via [custom.catapult] in starship.toml; fall back otherwise.
if [[ -z "${STARSHIP_SHELL:-}" ]]; then
    export PS1="[cat-${CATAPULT_VER}] ${PS1:-}"
fi
