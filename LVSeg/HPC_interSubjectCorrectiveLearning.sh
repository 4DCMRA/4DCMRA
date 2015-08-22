#!/bin/bash
if [[ -z ${ANTSPATH} ]];then
  export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"
fi
ROOT_PATH="/hpc/home/pangjx/4DCMRA/Data/"

LOO_PATH="${ROOT_PATH}/LV/LOO/Set3/O4D13X/RS3RP2/JLF_1Mod_1_2/"
WARP_PATH="${ROOT_PATH}/LV/LOO/Set3/O4D13X/Warp/"
ATLASIZE=5
MANUAL_SEG_PREFIX="seg_1_2"
TEST_SUB_DIR="Test1"

TEMPLATE_ITER=5

#Learning Parms
RD=2x2x2
RF=3x3x3
RATE=0.1
ITERATION=2000
CHANNEL=3
LEARNING_FLAG=0

#MRF PARMs
MRF_BETA=1
MRF_ITER=10
SA_SUB_DIR="MRF_${MRF_BETA}_${MRF_ITER}"
# IO

GRID_OUTPUTPATH="${ROOT_PATH}/GridOutput/"
PROJECT_NAME="CL_${TEST_SUB_DIR}"
CORRECTION_PATH="${LOO_PATH}/Correction/${TEST_SUB_DIR}/"	

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

if [[ ! -d ${CORRECTION_PATH} ]];then
	mkdir -p ${CORRECTION_PATH}
fi

SA_OUT_DIR="${CORRECTION_PATH}/${SA_SUB_DIR}/"
if [[ ! -d ${SA_OUT_DIR} ]];then
	mkdir -p ${SA_OUT_DIR}
fi


for (( l = 0; l < 3; l++))
do
	for (( SKIPPED = 1; SKIPPED <= ${ATLASIZE}; SKIPPED++ ))
	do
		FEATURE_IMGS=""
		MS_IMGS=""
		AS_IMGS=""
		MASK_IMGS=""		
		CL_OUTPUT_PREFIX="${CORRECTION_PATH}/CL_sub${SKIPPED}"	
		for (( t = 1 ; t <= ${ATLASIZE} ; t++))
		do
			#target -- subject
			if [[ ${t} -eq ${SKIPPED} ]];then
				continue;
			fi
			TEMPLATE_PATH="${ROOT_PATH}/Templates/${FOLDER[${t}]}/"

			MANUAL_IMG="${TEMPLATE_PATH}/${MANUAL_SEG_PREFIX}.nii.gz"
			TARGET_MASK="${TEMPLATE_PATH}/msk${TEMPLATE_ITER}.nii.gz"	
			
			AUTO_SEG="${LOO_PATH}/joint${t}.nii.gz"

			if [[ ! -f ${MANUAL_IMG} ]];then
				echo "Can't read ${MASK_IMG} "
				exit -1
			fi

			if [[ ! -f ${AUTO_SEG} ]];then
				echo "Can't read ${AUTO_SEG} "
				exit -1
			fi

			MS_IMGS="${MS_IMGS} ${MANUAL_IMG} "
			AS_IMGS="${AS_IMGS} ${AUTO_SEG}"
			MASK_IMGS="${MASK_IMGS} ${TARGET_MASK}"

			
			FEATURE_N4IMG="${TEMPLATE_PATH}/avg${TEMPLATE_ITER}.nii.gz" #Feature 1
			FEATURE_SUSAN="${TEMPLATE_PATH}/susan${TEMPLATE_ITER}.nii.gz" #Feature 2
			FEATURE_SEG_P="${LOO_PATH}/joint${t}p000${l}.nii.gz" #Feature 3
				
			FEATURE_IMGS="${FEATURE_IMGS} ${FEATURE_N4IMG} ${FEATURE_SUSAN} ${FEATURE_SEG_P} "

			if [[ ! -f ${FEATURE_N4IMG} ]] || [[ ! -f ${FEATURE_SUSAN} ]] || [[ ! -f ${FEATURE_SEG_P} ]];then
				echo "Can't find ${FEATURE_N4IMG} or ${FEATURE_SUSAN} or ${FEATURE_SEG_P} "
				exit -1
			fi
		# End of target images
		done
		CL_CMD=" 3 -ms ${MS_IMGS} -as ${AS_IMGS} -f ${FEATURE_IMGS} -m ${MASK_IMGS} \
	 		-rd ${RD} -rf ${RF} -rate ${RATE} -c ${CHANNEL} -i ${ITERATION} -tl ${l} \
	 		${CL_OUTPUT_PREFIX} "
		if [[ LEARNING_FLAG -eq 1 ]]; then
			qsubProc "${PROJECT_NAME}_CL_T${SKIPPED}_L${l}" "${ANTSPATH}/bl ${CL_CMD} "
		fi
	# End of leave-one-out skipped images
	done	
# End of 3 labels
done

for (( t = 1; t <= ${ATLASIZE}; t++))
do
	TEMPLATE_PATH="${ROOT_PATH}/Templates/${FOLDER[${t}]}/"		
	
	AUTO_SEG="${LOO_PATH}/joint${t}.nii.gz"
	MASK_IMG="${TEMPLATE_PATH}/msk${TEMPLATE_ITER}.nii.gz"
	
	CL_OUTPUT_PREFIX="${CORRECTION_PATH}/CL_sub${t}"
	
	FEATURE_N4IMG="${TEMPLATE_PATH}/avg${TEMPLATE_ITER}.nii.gz" #Feature 1
	FEATURE_SUSAN="${TEMPLATE_PATH}/susan${TEMPLATE_ITER}.nii.gz" #Feature 2
	FEATURE_SEG_P="${LOO_PATH}/joint${t}p%04d.nii.gz" #Feature 3
		
	FEATURE_IMGS="${FEATURE_N4IMG} ${FEATURE_SUSAN} ${FEATURE_SEG_P} "

	SA_OUT_PREFIX="${SA_OUT_DIR}/joint${t}"
	

	if [[ -f ${AUTO_SEG} ]];then
		SA_CMD=" ${AUTO_SEG} ${CL_OUTPUT_PREFIX} ${SA_OUT_PREFIX}.nii.gz \
	 	-f ${FEATURE_IMGS} -p ${SA_OUT_PREFIX}_p%04d.nii.gz \
	 	-mrf ICM[${MRF_BETA} ${MRF_ITER}] "
		qsubProcHold "${PROJECT_NAME}_CL_T*" "${PROJECT_NAME}_SA_${t}" "${ANTSPATH}/sa ${SA_CMD}"
	fi
done
