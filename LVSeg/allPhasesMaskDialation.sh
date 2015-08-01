export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"

#I/O
ROOT_PATH="/hpc/home/pangjx/4DCMRA/Data"
CASE_ROOT_DIR="$ROOT_PATH/Cases/"
WH_MASK_DIR="WholeHeartMask"
DIALTED_MASK_DIR="DilatedMask"
SMOOTHED_MASK_DIR="SmoothedMask"
PROJECT_JOB_NAME="MX"

#Parms
MD_RADIUS=2
SM_SIGMA=5
PHASE_NUMBER=16

CASE_DIRS=`ls -l --time-style="long-iso" ${CASE_ROOT_DIR}  | egrep '^d' | awk '{print $8}'`


function qsubProc(){
  ## 1: Job name
  ## 2: commands
  qsub -cwd -j y -o "${OUTPUTPATH}" -N ${1} ../wrapper.sh ${2}
}

for CASE_DIR in ${CASE_DIRS}
do
	CASE_FULL_PATH="${CASE_ROOT_DIR}/${CASE_DIR}"
	for (( i = 1; i <=$PHASE_NUMBER; i++ ))
	do
		MASK_IMG="${CASE_FULL_PATH}/${WH_MASK_DIR}/mask${i}.nii.gz"
		DILATED_IMG="${CASE_FULL_PATH}/${DIALTED_MASK_DIR}/mask${i}.nii.gz"
		SMOOTHED_IMG="${CASE_FULL_PATH}/${SMOOTHED_MASK_DIR}/mask${i}.nii.gz"
		DL_CMD=" 3 ${DILATED_IMG} MD ${MASK_IMG} ${MD_RADIUS} "
		SM_CMD=" 3 ${MASK_IMG} ${SM_SIGMA} ${SMOOTHED_IMG} "
		
		#Dialation
		qsubProc "${PROJECT_JOB_NAME}_${CASE_DIR}_DL" "${ANTSPATH}/ImageMath ${DL_CMD}"
		qsubProc "${PROJECT_JOB_NAME}_${CASE_DIR}_SM" "${ANTSPATH}/SmoothImage ${SM_CMD}"
	done
done

