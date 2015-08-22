export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"

#INPUT ARGUMENT
# REG_SUB DIR TRAN_SUB_DIR

# I/O
ROOT_PATH="/hpc/home/pangjx/4DCMRA/Data"

CASE_ROOT_DIR="$ROOT_PATH/Cases/"
REG_OUT_ROOT_DIR="${ROOT_PATH}/PhaseReg/"
TRAN_OUT_ROOT_DIR="${REG_OUT_ROOT_DIR}"

#Reg Parms

PHASE_NUMBER=16
MANUAL_SUB_DIR="Manual"
if [[ ${#} -lt 1 ]];then
	echo "Usage ${0} NAME_SAME_AS_REGISTRATION e.g 05D2X"
	exit -1
fi
CODE_NAME=${1}
REG_PROJECT_JOB_NAME="REG_${CODE_NAME}"
REG_SUB_DIR="WARP_${CODE_NAME}"
TRAN_SUB_DIR="TRAN_${CODE_NAME}"
PROJECT_JOB_NAME="T_${CODE_NAME}"

THREAD_NUMBER=1

CASE_DIRS=`ls -l --time-style="long-iso" ${CASE_ROOT_DIR}  | egrep '^d' | awk '{print $8}'`
OUTPUTPATH="${ROOT_PATH}/GridOutput/"


# Grid Engine code
function qsubProc(){
  ## 1: Job name
  ## 2: commands
  qsub -cwd -j y -o "${OUTPUTPATH}" -N ${1} ../wrapper.sh ${2}
}

function qsubProcHold(){
  ## 1: hold Job name
  ## 2: Job name
  ## 3: commands
  qsub -cwd -j y -o "${OUTPUTPATH}" -hold_jid ${1} -N ${2} ../wrapper.sh ${3}
}

function adjustIndex(){
	if [[ ${1} -gt ${PHASE_NUMBER} ]];then
		ADJUSTED_OUTPUT=$((${1}-${PHASE_NUMBER}))		
	else
		ADJUSTED_OUTPUT=${1}
	fi

}

if [[ ! -d ${OUTPUTPATH} ]];then
	mkdir -p $OUTPUTPATH
fi

for CASE_DIR in ${CASE_DIRS}
do
	REG_OUT_DIR="${REG_OUT_ROOT_DIR}/${CASE_DIR}"
	TRAN_OUT_DIR="${REG_OUT_DIR}"

	INPUTPATH="${CASE_ROOT_DIR}/${CASE_DIR}"
	WARPPATH="${REG_OUT_DIR}/${REG_SUB_DIR}/"
	TRANPATH="${REG_OUT_DIR}/${TRAN_SUB_DIR}/"
	
	REG_JOB_NAME_PREFIX="${REG_PROJECT_JOB_NAME}_${CASE_DIR}_REG"
	TRAN_JOB_NAME_PREFIX="${PROJECT_JOB_NAME}_${CASE_DIR}_TRAN"

	if [[ ! -d ${TRANPATH} ]];then
		mkdir -p ${TRANPATH}
	fi

	for (( i = 1; i <= ${PHASE_NUMBER}; i++))
	do
	    TRAN_JOB_NAME="${TRAN_JOB_NAME_PREFIX}_p${i}"

	    INPUT_LABEL="${INPUTPATH}/Manual/seg${i}.nii.gz"
	    INPUT_IMG="${INPUTPATH}/phase${i}.nii"


		OUTPUT_PREFIX="${TRANPATH}/seg${i}"
		OUTPUT_IMG_PREFIX="${TRANPATH}/img${i}"
        
        TRAN_CMD=" -d 3 -f 0 --verbose 1 --float -r ${INPUT_IMG} "

	    TRAN_FILE_STR1=""
	    for (( j = 0; j < ${PHASE_NUMBER}; j++))
	    do
			adjustIndex $((${i}+${j}))
			MOVING_INDEX=${ADJUSTED_OUTPUT}

			adjustIndex $((${i}+${j}+1))
			TARGET_INDEX=${ADJUSTED_OUTPUT}

			WARP_PREFIX="${WARPPATH}/reg${MOVING_INDEX}t${TARGET_INDEX}"
			TRAN_FILE_STR1=" -t ${WARP_PREFIX}1Warp.nii.gz -t ${WARP_PREFIX}0GenericAffine.mat ${TRAN_FILE_STR1}"
	    done

	    if [[ -f ${INPUT_LABEL} ]];then
	        OUTPUT_LABEL1="${OUTPUT_PREFIX}_1.nii.gz"
	        TRAN_FORWARD_LABEL="${TRAN_CMD} -n NearestNeighbor -i ${INPUT_LABEL} -o ${OUTPUT_LABEL1} ${TRAN_FILE_STR1}"
	        if [[ ! -f ${OUTPUT_LABEL1} ]];then
				qsubProcHold "${REG_JOB_NAME_PREFIX}*" "${TRAN_JOB_NAME}_L1" "${ANTSPATH}/antsApplyTransforms ${TRAN_FORWARD_LABEL}"
			fi
	    fi
		
		OUTPUT_IMG1="${OUTPUT_IMG_PREFIX}_1.nii.gz"
		TRAN_FORWARD_IMG="${TRAN_CMD} -n Linear -i ${INPUT_IMG} -o ${OUTPUT_IMG1} ${TRAN_FILE_STR1}"		
        if [[ ! -f ${OUTPUT_IMG1} ]];then
			qsubProcHold "${REG_JOB_NAME_PREFIX}*" "${TRAN_JOB_NAME}_I1" "${ANTSPATH}/antsApplyTransforms ${TRAN_FORWARD_IMG}"
		fi

  #       OUTPUT_LABEL2="${OUTPUT_PREFIX}_2.nii.gz"
		# TRAN_FILE_STR2=""
	 #    for (( j = 0; j < ${PHASE_NUMBER}; j++))
	 #    do
		# 	adjustIndex $((${i}+${j}))
		# 	MOVING_INDEX=${ADJUSTED_OUTPUT}

		# 	adjustIndex $((${i}+${j}+1))
		# 	TARGET_INDEX=${ADJUSTED_OUTPUT}

		# 	WARP_PREFIX="${WARPPATH}/reg${MOVING_INDEX}t${TARGET_INDEX}"
		# 	TRAN_FILE_STR2="${TRAN_FILE_STR2} -t [${WARP_PREFIX}0GenericAffine.mat,1] -t ${WARP_PREFIX}1InverseWarp.nii.gz "
	 #    done
  #       TRAN_BACKWARD_CMD="${TRAN_CMD} -o ${OUTPUT_LABEL2} ${TRAN_FILE_STR2}"

  #       if [[ ! -f ${OUTPUT_LABEL2} ]];then
		# 	qsubProcHold "${REG_JOB_NAME_PREFIX}*" "${TRAN_JOB_NAME}_L2" "${ANTSPATH}/antsApplyTransforms ${TRAN_BACKWARD_CMD}"
		# fi

	done
	echo "${CASE_DIR}"
done