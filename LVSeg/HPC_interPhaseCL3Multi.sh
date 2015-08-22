#!/bin/bash
if [[ -z ${ANTSPATH} ]];then
  export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"
fi

SEG_SUB_DIR="seg_1_2"
TEST_SUB_DIR="MultiCL3LOO50_0.01_3x4"
PHASE_NUMBER=16
ATLAS_SIZE=5

#Learning Parms
RD=3x3x3
RF=4x4x4
RATE=0.01
ITERATION=50
CHANNEL=3
LEARNING_FLAG=1

#MRF PARMs
MRF_BETA=0
MRF_ITER=10
SA_SUB_DIR="MRF_${MRF_BETA}_${MRF_ITER}"

# IO
ROOT_PATH="/hpc/home/pangjx/4DCMRA/Data/"
LOO_PATH="${ROOT_PATH}/LV/LOO/Set3/"
LOO_JLF_PATH="${LOO_PATH}/O4D13X/RS3RP2/JLF_1Mod_1_2/"
CASE_ROOT_DIR="${ROOT_PATH}/Cases/"
GRID_OUTPUTPATH="${ROOT_PATH}/GridOutput/"
PROJECT_NAME="CLPHASE_${SEG_SUB_DIR}_${TEST_SUB_DIR}"
CORRECTION_PATH="${ROOT_PATH}/Correction/${SEG_SUB_DIR}/${TEST_SUB_DIR}/"	

# PHASE ALIGNMENT
SYS_DIA_PHASE_DISTANCE=10
SYS_PHASE[1]=1
SYS_PHASE[2]=5
SYS_PHASE[3]=5
SYS_PHASE[4]=16
SYS_PHASE[5]=16

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

function adjustPhaseNumber(){
	if [[ ${1} -gt ${PHASE_NUMBER} ]];then
		ADJUSTED_OUTPUT=$((${1} - ${PHASE_NUMBER}))
	else
		if [[ ${1} -lt 1 ]];then
			ADJUSTED_OUTPUT=$((${1} + ${PHASE_NUMBER}))
		else
			ADJUSTED_OUTPUT=${1}
		fi
	fi
}


if [[ ! -d ${CORRECTION_PATH} ]];then
	mkdir -p ${CORRECTION_PATH}
fi

for (( TARGET_CASE = 1; TARGET_CASE <= ${ATLAS_SIZE}; TARGET_CASE++))
do
	TARGET_DIR=${FOLDER[${TARGET_CASE}]}
	for (( l = 0 ; l < 3; l ++))
	do
		for (( p = 0 ; p < ${PHASE_NUMBER} ; p++))
		do
			FEATURE_IMGS=""
			MS_IMGS=""
			AS_IMGS=""	
			for (( i = 1 ; i <= ${ATLAS_SIZE} ; i++))
			do
				if [[ ${TARGET_CASE} -eq ${i} ]];then
					continue;
				fi
				CASE_DIR=${FOLDER[${i}]}
				adjustPhaseNumber	$(( ${p} + ${SYS_PHASE[${i}]} ))
				CURRENT_PHASE=${ADJUSTED_OUTPUT}
				MANUAL_DIR="${ROOT_PATH}/Cases/${CASE_DIR}/Manual/"
				N4_DIR="${ROOT_PATH}/Cases/${CASE_DIR}/N4Img/"
				SUSAN_DIR="${ROOT_PATH}/Cases/${CASE_DIR}/SUSAN/"
				LAP_DIR="${ROOT_PATH}/Cases/${CASE_DIR}/Laplacian/"
				TEMPLATE_PATH="${ROOT_PATH}/Templates/${CASE_DIR}/"
				
				CL_OUTPUT_PREFIX="${CORRECTION_PATH}/CL_t${TARGET_DIR}p${p}"
				

				adjustPhaseNumber $((${CURRENT_PHASE}-1))
				PHASE[0]=${ADJUSTED_OUTPUT}
				PHASE[1]=${CURRENT_PHASE}
				adjustPhaseNumber $((${CURRENT_PHASE}+1))
				PHASE[2]=${ADJUSTED_OUTPUT}

				MS_IMGS="${MS_IMGS} ${MANUAL_DIR}/seg${PHASE[0]}.nii.gz \
				 ${MANUAL_DIR}/seg${PHASE[1]}.nii.gz \
				 ${MANUAL_DIR}/seg${PHASE[2]}.nii.gz "
				AS_IMGS="${AS_IMGS} ${TEMPLATE_PATH}/${SEG_SUB_DIR}/seg${PHASE[0]}.nii.gz \
				${TEMPLATE_PATH}/${SEG_SUB_DIR}/seg${PHASE[1]}.nii.gz
				${TEMPLATE_PATH}/${SEG_SUB_DIR}/seg${PHASE[2]}.nii.gz"

				FEATURE_IMGS="${FEATURE_IMGS} ${N4_DIR}/img${PHASE[0]}.nii.gz ${SUSAN_DIR}/susan${PHASE[0]}.nii.gz ${LAP_DIR}/lap${PHASE[0]}.nii.gz \
				${TEMPLATE_PATH}/${SEG_SUB_DIR}/img${PHASE[1]}.nii.gz ${SUSAN_DIR}/susan${PHASE[1]}.nii.gz ${LAP_DIR}/lap${PHASE[1]}.nii.gz \
				${TEMPLATE_PATH}/${SEG_SUB_DIR}/img${PHASE[2]}.nii.gz ${SUSAN_DIR}/susan${PHASE[2]}.nii.gz ${LAP_DIR}/lap${PHASE[2]}.nii.gz "

			# End of different subjects
			done
		CL_CMD=" 3 -ms ${MS_IMGS} -as ${AS_IMGS} -f ${FEATURE_IMGS} \
	 		-rd ${RD} -rf ${RF} -rate ${RATE} -c ${CHANNEL} -i ${ITERATION} "			
		CL_CMD_LABEL=" ${CL_CMD} -tl ${l} "
		if [[ LEARNING_FLAG -eq 1 ]]; then
			qsubProc "${PROJECT_NAME}_T${TARGET_CASE}_P${p}_L${l}" "${ANTSPATH}/bl ${CL_CMD_LABEL} ${CL_OUTPUT_PREFIX}"
		fi	 		
		# End of phases
		done
	#End of label
	done
#End of Skipped
done

for (( i = 1 ; i <= ${ATLAS_SIZE} ; i++))
do
	CASE_DIR=${FOLDER[${i}]}
	for (( p = 0; p < ${PHASE_NUMBER}; p++))
	do
		adjustPhaseNumber	$(( ${p} + ${SYS_PHASE[${i}]} ))
		CURRENT_PHASE=${ADJUSTED_OUTPUT}
		CL_OUTPUT_PREFIX="${CORRECTION_PATH}/CL_t${CASE_DIR}p${p}"

		AUTO_IMG="${LOO_JLF_PATH}/InvTrans/${CASE_DIR}/seg${CURRENT_PHASE}.nii.gz"
		N4_DIR="${ROOT_PATH}/Cases/${CASE_DIR}/N4Img/"
		SUSAN_DIR="${ROOT_PATH}/Cases/${CASE_DIR}/SUSAN/"
		LAP_DIR="${ROOT_PATH}/Cases/${CASE_DIR}/Laplacian/"

		SA_OUT_DIR="${CORRECTION_PATH}/${SA_SUB_DIR}/${CASE_DIR}/"
		if [[ ! -d ${SA_OUT_DIR} ]];then
			mkdir -p ${SA_OUT_DIR}
		fi
		SA_OUT_PREFIX="${SA_OUT_DIR}/seg${CURRENT_PHASE}"
		FEATURE_IMGS="${N4_DIR}/img${CURRENT_PHASE}.nii.gz ${SUSAN_DIR}/susan${CURRENT_PHASE}.nii.gz ${LAP_DIR}/lap${CURRENT_PHASE}.nii.gz "

		if [[ -f ${AUTO_IMG} ]];then
			SA_CMD=" ${AUTO_IMG} ${CL_OUTPUT_PREFIX} ${SA_OUT_PREFIX}.nii.gz \
		 	-f ${FEATURE_IMGS} -p ${SA_OUT_PREFIX}_p%04d.nii.gz \
		 	-mrf ICM[${MRF_BETA} ${MRF_ITER}] "
			qsubProcHold "${PROJECT_NAME}_T${i}_P${p}*" "${PROJECT_NAME}_SA_${CASE_DIR}_P${CURRENT_PHASE}" "${ANTSPATH}/sa ${SA_CMD}"
		fi
	done
done

# Post-processing
./HPC_SmoothingDiceVolumen.sh ${CORRECTION_PATH}/${SA_SUB_DIR} "${PROJECT_NAME}_SA_"