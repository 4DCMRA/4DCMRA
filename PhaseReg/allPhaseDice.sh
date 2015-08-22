#!/bin/bash
if [[ -z ${ANTSPATH} ]];then
  export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"
fi

#INPUT
# #1 TRAN_SUB_FOLDER
if [[ ${#} -lt 1 ]];then
	echo "Usage ${0} CODE_NAME_SAME_AS_REG_TRAN"
	exit -1
else
	CODE_NAME=${1}
fi

# I/O
ROOT_PATH="/hpc/home/pangjx/4DCMRA/Data"
CASE_ROOT_DIR="$ROOT_PATH/Cases/"
TRAN_OUT_ROOT_DIR="${ROOT_PATH}//PhaseReg/"
TRAN_SUB_DIR="TRAN_${CODE_NAME}"

# Settting
PHASENUMBER=16
AS_PREFIX="seg"

CASE_DIRS=`ls -l --time-style="long-iso" ${CASE_ROOT_DIR}  | egrep '^d' | awk '{print $8}'`
GRID_OUTPUTPATH="${ROOT_PATH}/GridOutput/"


# Grid Engine code
function qsubProc(){
  ## 1: Job name
  ## 2: commands
  qsub -cwd -j y -o "${GRID_OUTPUTPATH}" -N ${1} ../wrapper.sh ${2}
}

function qsubProcHold(){
  ## 1: hold Job name
  ## 2: Job name
  ## 3: commands
  qsub -cwd -j y -o "${GRID_OUTPUTPATH}" -hold_jid ${1} -N ${2} ../wrapper.sh ${3}
}

SUM_DICE_FILE="${TRAN_OUT_ROOT_DIR}/Dice_${CODE_NAME}.csv"
for CASE_DIR in ${CASE_DIRS}
do
	TRAN_OUT_DIR="${TRAN_OUT_ROOT_DIR}/${CASE_DIR}"
	INPUTPATH="${CASE_ROOT_DIR}/${CASE_DIR}/Manual"
	if [[ -d ${INPUTPATH} ]];then
		TRANPATH="${TRAN_OUT_DIR}/${TRAN_SUB_DIR}/"
		DICE_OUT_PATH="${TRANPATH}/Dice/"
		DICE_FILENAME_STR=" "
		qsubProcHold "T_${CODE_NAME}_${CASE_DIR}*" "DICE_${CODE_NAME}_${CASE_DIR}" "../AutoMask/crossValidation.sh -i ${INPUTPATH} -a ${TRANPATH} \
		-o ${DICE_OUT_PATH} -p ${AS_PREFIX} -s ${PHASENUMBER} -e ${SUM_DICE_FILE}"	
	fi
done

