#!/bin/bash
if [[ -z ${ANTSPATH} ]];then
  export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"
fi

SEG_SUB_DIR="seg_1_2"
TEST_SUB_DIR="Test1"
PHASE_NUMBER=16

#Learning Parms
RD=2x2x2
RF=2x2x2
RATE=0.01
ITERATION=1000
CHANNEL=1
LEARNING_FLAG=0

#MRF PARMs
MRF_BETA=0.05
MRF_ITER=10
SA_SUB_DIR="MRF_${MRF_BETA}_${MRF_ITER}"
# IO
ROOT_PATH="/hpc/home/pangjx/4DCMRA/Data/"
CASE_ROOT_DIR="${ROOT_PATH}/Cases/"
GRID_OUTPUTPATH="${ROOT_PATH}/GridOutput/"
PROJECT_NAME="CL_${SEG_SUB_DIR}_${TEST_SUB_DIR}"
CORRECTION_PATH="${ROOT_PATH}/Correction/${SEG_SUB_DIR}/${TEST_SUB_DIR}/"	

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


CASE_DIRS=`ls -l --time-style="long-iso" ${CASE_ROOT_DIR}  | egrep '^d' | awk '{print $8}'`

CL_OUTPUT_PREFIX="${CORRECTION_PATH}/CL"
WARPED_IMGS=""
MS_IMGS=""
AS_IMGS=""

if [[ ! -d ${CORRECTION_PATH} ]];then
	mkdir -p ${CORRECTION_PATH}
fi

for CASE_DIR in ${CASE_DIRS}
do
	MANUAL_DIR="${ROOT_PATH}/Cases/${CASE_DIR}/Manual/"		
	TEMPLATE_PATH="${ROOT_PATH}/Templates/${CASE_DIR}/"
	
	MANUAL_IMG="${MANUAL_DIR}/seg1.nii.gz"
	AUTO_IMG="${TEMPLATE_PATH}/${SEG_SUB_DIR}/seg1.nii.gz"

	if [[ -f ${MANUAL_IMG} ]] && [[ -f ${AUTO_IMG} ]];then

		MS_IMGS="${MS_IMGS} ${MANUAL_DIR}/seg*.nii.gz "
		AS_IMGS="${AS_IMGS} ${TEMPLATE_PATH}/${SEG_SUB_DIR}/seg*.nii.gz"
		WARPED_IMGS="${WARPED_IMGS} ${TEMPLATE_PATH}/${SEG_SUB_DIR}/img*.nii.gz"
	fi
done

CL_CMD=" 3 -ms ${MS_IMGS} -as ${AS_IMGS} -f ${WARPED_IMGS} \
 -rd ${RD} -rf ${RF} -rate ${RATE} -c ${CHANNEL} -i ${ITERATION} "

for (( LABEL=0; LABEL<3; LABEL++))
do
	CL_CMD_LABEL=" ${CL_CMD} -tl ${LABEL} "
	if [[ LEARNING_FLAG -eq 1 ]]; then
		qsubProc "${PROJECT_NAME}_CLT${LABEL}" "${ANTSPATH}/bl ${CL_CMD_LABEL} ${CL_OUTPUT_PREFIX}"
	fi
done

for CASE_DIR in ${CASE_DIRS}
do
	for (( p = 1; p <= ${PHASE_NUMBER}; p++))
	do
		MANUAL_DIR="${ROOT_PATH}/Cases/${CASE_DIR}/Manual/"		
		TEMPLATE_PATH="${ROOT_PATH}/Templates/${CASE_DIR}/"		

		AUTO_IMG="${TEMPLATE_PATH}/${SEG_SUB_DIR}/seg${p}.nii.gz"
		SA_OUT_DIR="${CORRECTION_PATH}/${SA_SUB_DIR}/${CASE_DIR}/"
		if [[ ! -d ${SA_OUT_DIR} ]];then
			mkdir -p ${SA_OUT_DIR}
		fi
		SA_OUT_PREFIX="${SA_OUT_DIR}/seg${p}"
		WARPED_IMG="${TEMPLATE_PATH}/${SEG_SUB_DIR}/img${p}.nii.gz"

		if [[ -f ${AUTO_IMG} ]];then
			SA_CMD=" ${AUTO_IMG} ${CL_OUTPUT_PREFIX} ${SA_OUT_PREFIX}.nii.gz \
		 	-f ${WARPED_IMG} -p ${SA_OUT_PREFIX}_posterior%04d.nii.gz \
		 	-mrf ICM[${MRF_BETA} ${MRF_ITER}] "
			qsubProcHold "${PROJECT_NAME}_CLT*" "${PROJECT_NAME}_SA_${CASE_DIR}_${p}" "${ANTSPATH}/sa ${SA_CMD}"
		fi
	done
done
