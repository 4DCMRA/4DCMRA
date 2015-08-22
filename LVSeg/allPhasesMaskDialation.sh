export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"
export FSLDIR="/hpc/apps/fsl/5.0.4/"

# I/O
ROOT_PATH="/hpc/home/pangjx/4DCMRA/Data"
CASE_ROOT_DIR="$ROOT_PATH/Cases/"
WH_MASK_SUBDIR="WholeHeartMask"
DIALTED_SUBDIR="DilatedMask"
SMOOTHED_SUBDIR="SmoothedMask"
N4_SUBDIR="N4Img"
SUSAN_SUBDIR="SUSAN"
LAP_SUBDIR="Laplacian"
PROJECT_JOB_NAME="MX"

# Smoothing Parms
MD_RADIUS=5
SM_SIGMA=5
PHASE_NUMBER=16

# N4 Parms
N4CONVERGENCE="[50x50x50x50,0.0]"
N4SHRINKFACTOR=2
PRESEVED_VALUE=0

# SUSAN Parms
BT=35
DT=2

# Lap Parms
LAP_RADIUS=2

CASE_DIRS=`ls -l --time-style="long-iso" ${CASE_ROOT_DIR}  | egrep '^d' | awk '{print $8}'`
OUTPUTPATH="${ROOT_PATH}/GridOutput/"
mkdir -p $OUTPUTPATH


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


for CASE_DIR in ${CASE_DIRS}
do
	CASE_FULL_PATH="${CASE_ROOT_DIR}/${CASE_DIR}"
	DL_PATH="${CASE_FULL_PATH}/${DIALTED_SUBDIR}"
	SM_PATH="${CASE_FULL_PATH}/${SMOOTHED_SUBDIR}"
	N4_PATH="${CASE_FULL_PATH}/${N4_SUBDIR}"
	SUSAN_PATH="${CASE_FULL_PATH}/${SUSAN_SUBDIR}"
	LAP_PATH="${CASE_FULL_PATH}/${LAP_SUBDIR}"
	mkdir -p ${DL_PATH} ${SM_PATH} ${N4_PATH} ${SUSAN_PATH} ${LAP_PATH}

	for (( i = 1; i <=$PHASE_NUMBER; i++ ))
	do
		INPUT_IMG="${CASE_FULL_PATH}/phase${i}.nii"		
		MASK_IMG="${CASE_FULL_PATH}/${WH_MASK_SUBDIR}/mask${i}.nii.gz"
		if [[ -f ${MASK_IMG} ]];then
			DILATED_MASK="${DL_PATH}/mask${i}.nii.gz"
			SMOOTHED_MASK="${SM_PATH}/mask${i}.nii.gz"
			DL_CMD=" 3 ${DILATED_MASK} MD ${MASK_IMG} ${MD_RADIUS} "
			SM_CMD=" 3 ${MASK_IMG} ${SM_SIGMA} ${SMOOTHED_MASK} "
			
			#Dialation
			MASK_JOB_PREFIX="${PROJECT_JOB_NAME}_${CASE_DIR}_${i}_MASK"
			DL_JOB_NAME="${MASK_JOB_PREFIX}_DL"
			SM_JOB_NAME="${MASK_JOB_PREFIX}_SM"
			qsubProc ${DL_JOB_NAME}  "${ANTSPATH}/ImageMath ${DL_CMD}"
			qsubProc ${SM_JOB_NAME} "${ANTSPATH}/SmoothImage ${SM_CMD}"

			#N4 Biase
			N4_JOB_NAME="${PROJECT_JOB_NAME}_${CASE_DIR}_${i}_N4"

			N4_OUTPUT_IMG="${N4_PATH}/img${i}.nii.gz"
			N4CRTCMD="-d 3 -c ${N4CONVERGENCE} -s ${N4SHRINKFACTOR} \
					-i ${INPUT_IMG} -o  ${N4_OUTPUT_IMG} \
					 --verbose -r ${PRESEVED_VALUE}"
			# N4CRTCMD="${N4CRTCMD} -x ${DILATED_MASK}"
		    N4CRTCMD="${N4CRTCMD} -w ${SMOOTHED_MASK}"
			qsubProcHold "${MASK_JOB_PREFIX}*" ${N4_JOB_NAME} "${ANTSPATH}/N4BiasFieldCorrection ${N4CRTCMD}" 

			#SUSAN
			SUSAN_JOB_NAME="${PROJECT_JOB_NAME}_${CASE_DIR}_${i}_SUSAN"
			SUSAN_OUTPUT_IMG="${SUSAN_PATH}/susan${i}.nii.gz"
			SUSANCMD=" ${N4_OUTPUT_IMG} ${BT} ${DT} 3 1 0 ${SUSAN_OUTPUT_IMG} "
			
			qsubProcHold ${N4_JOB_NAME} "${SUSAN_JOB_NAME}" "${FSLDIR}/bin/susan ${SUSANCMD}"

			#Laplacian
			LAP_JOB_NAME="${PROJECT_JOB_NAME}_${CASE_DIR}_${i}_LAP"
			LAP_OUTPUT_IMG="${LAP_PATH}/lap${i}.nii.gz"
			LAPCMD=" 3 ${LAP_OUTPUT_IMG} Laplacian ${SUSAN_OUTPUT_IMG} ${LAP_RADIUS} 1"
			
			qsubProcHold ${SUSAN_JOB_NAME} "${LAP_JOB_NAME}" "${ANTSPATH}/ImageMath ${LAPCMD}"
			echo "${i}/${PHASE_NUMBER}"
		fi
	done
	echo "${CASE_DIR} is done"
done