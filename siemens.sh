export CATAPULT_VER=${CATAPULT_VER:-2026.1}

export QUESTASIM_VER=2025.2_2

export CATAPULT_PATH=/extras2/tools/Siemens/catapult/${CATAPULT_VER}

export MGC_HOME=${CATAPULT_PATH}/Mgc_home
export CATAPULT_HOME=${CATAPULT_PATH}/Mgc_home
export SYSTEMC=${CATAPULT_PATH}/Mgc_home/shared
export SYSTEMC_HOME=${SYSTEMC}
export LIBDIR="-L${CATAPULT_PATH}/Mgc_home/shared/lib ${LIBDIR}"
export LD_LIBRARY_PATH=${CATAPULT_PATH}/Mgc_home/lib:${CATAPULT_PATH}/Mgc_home/shared/lib:${BOOST_HOME}/lib:${LD_LIBRARY_PATH}
#export CCOV_HOME=/asic/cad/mentor/catapult/ccov

#export NC_ROOT=/asic/cad/cadence/XCELIUM2109

export MODELTECH=/extras2/tools/Siemens/Questa/${QUESTASIM_VER}/questasim/bin
export MODEL_TECH=${MODELTECH}

export PATH=${CATAPULT_PATH}/Mgc_home/bin:${MODELTECH}:${PATH}
export LM_LICENSE_FILE=40003@localhost:$LM_LICENSE_FILE
export SALT_LICENSE_SERVER=40003@localhost
export PS1="[siemens] ${PS1}"
