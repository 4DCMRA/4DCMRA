export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"

if [[ ${#} -lt 3 ]];then
	echo "Usage ${0} NAME_OF_REGISTRATION BSPLINE_DISTANCE BSPLINE_ORDER e.g 05D2X 2x2x2 5"
	exit -1
fi
CODE_NAME=${1}
# I/O
ROOT_PATH="/hpc/home/pangjx/4DCMRA/Data"
CASE_ROOT_DIR="${ROOT_PATH}/Cases/"
REG_OUT_ROOT_DIR="${ROOT_PATH}/PhaseReg/"
WARP_SUB_DIR="WARP_${1}"
#Reg Parms
PROJECT_JOB_NAME="REG_${1}"
PHASE_NUMBER=16
REGISTRATION_SCRIPT="../RegScripts/BSyN_metric0.sh"
SPLINE_DISTANCE=${2}
SPLINE_ORDER=${3}
TRANSFORMTYPE='b'
HISTOGRAM_MATCHING=1
THREAD_NUMBER=16

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

if [[ ! -d ${OUTPUTPATH} ]];then
	mkdir -p $OUTPUTPATH
fi

for CASE_DIR in ${CASE_DIRS}
do
	INPUTPATH="${CASE_ROOT_DIR}/${CASE_DIR}"
	REG_JOB_NAME_PREFIX="${PROJECT_JOB_NAME}_${CASE_DIR}_REG"

	REG_OUT_DIR="${REG_OUT_ROOT_DIR}/${CASE_DIR}"
	WARPPATH="${REG_OUT_DIR}/${WARP_SUB_DIR}/"
	if [[ ! -d ${WARPPATH} ]];then
		mkdir -p ${WARPPATH}
	fi

	for (( i = 1; i <= ${PHASE_NUMBER}; i++))
	do
		if [[ ${i} == ${PHASE_NUMBER} ]];then
			target=1;
		else
			target=$((i+1))
		fi

	    REG_JOB_NAME="${REG_JOB_NAME_PREFIX}_t${target}m${i}"

		FIXED_IMG="${INPUTPATH}/N4Img/img${target}.nii.gz"
    	MOVING_IMG="${INPUTPATH}/N4Img/img${i}.nii.gz"

        OUTPUT_PREFIX="${WARPPATH}/reg${i}t${target}"

        REG_CMD=" -d 3 -t ${TRANSFORMTYPE} -n ${THREAD_NUMBER} -j ${HISTOGRAM_MATCHING} \
         -f ${FIXED_IMG} -m ${MOVING_IMG} -o ${OUTPUT_PREFIX} -s ${SPLINE_DISTANCE} -e ${SPLINE_ORDER}"

        # Smoothed Mask 
		FIXED_SMOOTHED_MASK="${INPUTPATH}/SmoothedMask/mask${target}.nii.gz"
		MOVING_SMOOTHED_MASK="${INPUTPATH}/SmoothedMask/mask${i}.nii.gz"
		# REG_CMD="${REG_CMD} -x[${FIXED_SMOOTHED_MASK},${MOVING_SMOOTHED_MASK}]"

		#Mask
		FIXED_MASK="${INPUTPATH}/DilatedMask/mask${target}.nii.gz"
		MOVING_MASK="${INPUTPATH}/DilatedMask/mask${i}.nii.gz"
		REG_CMD="${REG_CMD} -f ${FIXED_MASK} -m ${MOVING_MASK} "
		REG_CMD="${REG_CMD} -x[${FIXED_MASK},${MOVING_MASK}]"		

		# SUSAN
		FIXED_SUSAN="${INPUTPATH}/SUSAN/susan${target}.nii.gz"
		MOVING_SUSAN="${INPUTPATH}/SUSAN/susan${i}.nii.gz"
		REG_CMD="${REG_CMD} -f ${FIXED_SUSAN} -m ${MOVING_SUSAN} "		

		# Laplacian
		FIXED_LAP="${INPUTPATH}/Laplacian/lap${target}.nii.gz"
		MOVING_LAP="${INPUTPATH}/Laplacian/lap${i}.nii.gz"
		REG_CMD="${REG_CMD} -f ${FIXED_LAP} -m ${MOVING_LAP} "		

        if [[ ! -f "${OUTPUT_PREFIX}0GenericAffine.mat" ]];then
			qsubProc "${REG_JOB_NAME}_REG" "${REGISTRATION_SCRIPT} ${REG_CMD}"
		fi
	done
	echo "${CASE_DIR}"
done