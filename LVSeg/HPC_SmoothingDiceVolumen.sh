if [[ -z ${ANTSPATH} ]];then
  export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"
fi

# Smoothing 
SIGMAS=2
ROOT_PATH="/hpc/home/pangjx/4DCMRA/Data/"
PROJECT_NAME="QA"
ATLAS_SIZE=5
PHASE_NUMBER=16


HOLD_JID=""
if [[ ${#} -lt 1 ]];then
	echo "Usage: ${0} segmentation_path [hold_jid]"
	exit -1;
else
	SEG_PATH=${1}
fi
if [[ ${#} -ge 2 ]];then
	HOLD_JID=${2}
fi
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


# IO
ROOT_PATH="/hpc/home/pangjx/4DCMRA/Data/"


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

PHASE_DICE_CSV="${SEG_PATH}/PhaseDice_${SIGMAS}.csv"
if [[ -f ${PHASE_DICE_CSV} ]];then
	rm ${PHASE_DICE_CSV}
fi

VOL_SUMMARY_FILE="${SEG_PATH}/Vol_Summary_${SIGMAS}.csv"
if [[ -f ${VOL_SUMMARY_FILE} ]];then
	rm ${VOL_SUMMARY_FILE}
fi

if [[ ! -z ${HOLD_JID} ]];then
	PROJECT_NAME="${PROJECT_NAME}_${HOLD_JID}"
fi

for (( i = 1 ; i <= ${ATLAS_SIZE} ; i++))
do
	CASE_DIR=${FOLDER[${i}]};
	CASE_SEG_PATH=${SEG_PATH}/${CASE_DIR}
	SMOOTHED_PATH="${CASE_SEG_PATH}/Smoothed_${SIGMAS}"

	ATLAS_PATH="${ROOT_PATH}/Cases/${CASE_DIR}/Manual/"
	if [[ ! -d ${SMOOTHED_PATH} ]];then
		mkdir -p ${SMOOTHED_PATH}
	fi
	if [[ ! -d ${ATLAS_PATH} ]];then
		echo "Can't find the manual path ${ATLAS_PATH} "
		exit -1;
	fi
	for (( p = 1; p <= ${PHASE_NUMBER}; p++))
	do
		SEG_IMG="${CASE_SEG_PATH}/seg${p}.nii.gz"
		if [[ ! -f ${SEG_IMG} ]] && [[ -z ${HOLD_JID} ]];then
			echo "Can not find ${SEG_IMG} ";
			exit -1;
		fi
		OUT_SM_IMG="${SMOOTHED_PATH}/seg${p}.nii.gz"

		SMOOTHING_CMD="  3 ${SEG_IMG} ${SIGMAS} ${OUT_SM_IMG} 1 1 "
		if [[ ! -f ${OUT_SM_IMG} ]];then
			if [[ ! -z ${HOLD_JID} ]];then
				qsubProcHold "${HOLD_JID}*" "${PROJECT_NAME}_S${CASE_DIR}p${p}" "${ANTSPATH}/SmoothImage ${SMOOTHING_CMD}"
			else
				qsubProc "${PROJECT_NAME}_S${CASE_DIR}p${p}" "${ANTSPATH}/SmoothImage ${SMOOTHING_CMD}"
			fi
		fi
	done

	CV_CMD=" -a ${SMOOTHED_PATH} -i ${ATLAS_PATH} -s ${PHASE_NUMBER} -p seg -o ${SMOOTHED_PATH}/Dice -e ${PHASE_DICE_CSV} "
	qsubProcHold "${PROJECT_NAME}_S${CASE_DIR}*" "${PROJECT_NAME}_D${CASE_DIR}" "../AutoMask/crossValidation.sh ${CV_CMD}"
	VOL_CMD=" -i ${SMOOTHED_PATH} -s ${PHASE_NUMBER} -e ${VOL_SUMMARY_FILE} "
	qsubProcHold "${PROJECT_NAME}_S${CASE_DIR}*" "${PROJECT_NAME}_V${CASE_DIR}" "./labelVolume.sh ${VOL_CMD}"
done
