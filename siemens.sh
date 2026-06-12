#export CATAPULT_VER=2022.1
#export CATAPULT_VER=2024.2
#export CATAPULT_VER=2025.2_1
#export CATAPULT_VER=2025.4_1
#export CATAPULT_VER=2026.1
#export CATAPULT_VER=2026.1_1
export CATAPULT_VER=2026.2

#export QUESTASIM_VER=2025.2_2

export CATAPULT_PATH=/mnt/local/gdg/tools/cad/siemens/catapult/${CATAPULT_VER}

export MGC_HOME=${CATAPULT_PATH}/Mgc_home
export CATAPULT_HOME=${CATAPULT_PATH}/Mgc_home
export SYSTEMC=${CATAPULT_PATH}/Mgc_home/shared
export SYSTEMC_HOME=${SYSTEMC}
export LIBDIR="-L${CATAPULT_PATH}/Mgc_home/shared/lib ${LIBDIR}"
export LD_LIBRARY_PATH=${CATAPULT_PATH}/Mgc_home/lib:${CATAPULT_PATH}/Mgc_home/shared/lib:${BOOST_HOME}/lib:${LD_LIBRARY_PATH}
#export CCOV_HOME=/asic/cad/mentor/catapult/ccov

#export NC_ROOT=/asic/cad/cadence/XCELIUM2109

#export MODELTECH=/asic/cad/mentor/questa/questasim/bin
#export MODEL_TECH=${MODELTECH}

export PATH=${CATAPULT_PATH}/Mgc_home/bin:${MODELTECH}:${PATH}

# When starship is active it shows CATAPULT_VER via [custom.catapult] in starship.toml;
# fall back to a plain PS1 prefix otherwise.
if [ -z "${STARSHIP_SHELL:-}" ]; then
    export PS1="[siemens cat-${CATAPULT_VER}] ${PS1}"
fi
