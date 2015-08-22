#!/bin/bash
if [[ -z ${ANTSPATH} ]];then
  export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"
fi
ROOT_PATH="/hpc/home/pangjx/4DCMRA/Data/"

ATLAS_SIZE=5

LOO_PROJECT_NAME="LOOS3"
LOO_PATH="${ROOT_PATH}/LV/LOO/Set3/MV"
if [[ ${#} -lt 3 ]];then
	echo "Usage ${0} LOO_PROJECT_NAME LOO_PATH ATLAS_SIZE"
	exit -1
else
	LOO_PROJECT_NAME=${1}
	LOO_PATH=${2}
	ATLAS_SIZE=${3}
fi


#IO

MANUAL_ROOT_PATH="${ROOT_PATH}/Cases/"
TEMPLATE_ROOT_PATH="${ROOT_PATH}/Templates/"

OUTPUT_PATH="${LOO_PATH}/InvTrans/"
FUSION_JOB_PREFIX="${LOO_PROJECT_NAME}_F"
INVERSE_JOB_PREFIX="${LOO_PROJECT_NAME}_INV"
DICE_JOB_PREFIX="${LOO_PROJECT_NAME}_PHASEDICE"
VOLUME_JOB_PREFIX="${LOO_PROJECT_NAME}_VOL"
SUM_DICE_FILE="${OUTPUT_PATH}/dice.csv"
LOO_SEG_IMG_PREFIX="joint"
PHASE_NUMBER=16

if [[ ${ATLAS_SIZE} -eq 6 ]];then
	FOLDER[1]="case_684"
	FOLDER[2]="case_1206"
	FOLDER[3]="case_1241"
	FOLDER[4]="case_1253"
	FOLDER[5]="case_1265"
	FOLDER[6]="case_1266"
else
	FOLDER[1]="case_684"
	FOLDER[2]="case_1241"
	FOLDER[3]="case_1253"
	FOLDER[4]="case_1265"
	FOLDER[5]="case_1266"
fi

ITERATION=5

GRID_OUTPUTPATH="/hpc/home/pangjx/4DCMRA/Data//GridOutput/"
function qsubProc(){
  ## 1: Job name
  ## 2: commands
  qsub -cwd -j y -o "${GRID_OUTPUTPATH}" -N ${1} ../wrapper.sh ${2}
}

function qsubProcHold(){
  ## 1: Job name
  ## 2: commands
  qsub -cwd -j y -o "${GRID_OUTPUTPATH}" -hold_jid ${1} -N ${2} ../wrapper.sh ${3}
}



for (( i = 1; i <= ${ATLAS_SIZE}; i++))
do
	CASE_DIR="${FOLDER[${i}]}"
	MANUAL_PATH="${MANUAL_ROOT_PATH}/${CASE_DIR}/Manual"
	TEMPLATE_PATH="${TEMPLATE_ROOT_PATH}/${CASE_DIR}/"
	INVTRANS_PATH="${OUTPUT_PATH}/${CASE_DIR}"
	if [[ ! -d ${INVTRANS_PATH} ]];then
		mkdir -p ${INVTRANS_PATH}
	fi	
	INVERSE_LABEL_CMD=" -w ${TEMPLATE_PATH}/Iter$((${ITERATION}-1))/ -o ${INVTRANS_PATH} \
	 -s ${PHASE_NUMBER} -l ${LOO_PATH}/${LOO_SEG_IMG_PREFIX}${i}.nii.gz "

	INVERSE_IMAGE_CMD=" -w ${TEMPLATE_PATH}/Iter$((${ITERATION}-1))/ -o ${INVTRANS_PATH} \
	 -s ${PHASE_NUMBER} -l ${LOO_PATH}/susan${i}.nii.gz "	 
	 
	INVERSE_SUSAN_CMD=" -w ${TEMPLATE_PATH}/Iter$((${ITERATION}-1))/ -o ${INVTRANS_PATH} \
	 -s ${PHASE_NUMBER} -l ${LOO_PATH}/susan${i}.nii.gz "	 

	CROSSVALIDATION_CMD=" -a ${INVTRANS_PATH} -s ${ATLAS_SIZE} -i ${MANUAL_PATH} \
	 -o ${INVTRANS_PATH} -p seg -e ${LOO_PATH}/Phase_Dice.csv -s ${PHASE_NUMBER} "  
	qsubProcHold "${FUSION_JOB_PREFIX}*" "${INVERSE_JOB_PREFIX}_${CASE_DIR}" "./inversedTrans.sh ${INVERSE_LABEL_CMD}"
	qsubProcHold "${INVERSE_JOB_PREFIX}_${CASE_DIR}" "${DICE_JOB_PREFIX}_${CASE_DIR}" "../AutoMask/crossValidation.sh ${CROSSVALIDATION_CMD} "
	qsubProcHold "${INVERSE_JOB_PREFIX}_${CASE_DIR}" "${VOLUME_JOB_PREFIX}_${CASE_DIR}" "./labelVolume.sh -i ${INVTRANS_PATH} "
done