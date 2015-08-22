#!/bin/bash
if [[ -z ${ANTSPATH} ]];then
  export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"
fi

# I/O
TEMPLATE_ITERATION=5
ROOT_PATH="/hpc/home/pangjx/4DCMRA/Data"
CASE_ROOT_DIR="${ROOT_PATH}/Cases/"
TEMPLATE_INPUT="${ROOT_PATH}/Templates/"
OUT_ROOT_DIR="${ROOT_PATH}/Templates/"
WARP_SUB_DIR="Iter$((${TEMPLATE_ITERATION}-1))"
TRAN_SUB_DIR="Tran"

#Reg Parms
PROJECT_JOB_NAME="TemplateFusion"
PHASE_NUMBER=16
REGISTRATION_SCRIPT="../RegScripts/BSyN_metric0.sh"
SPLINE_DISTANCE=5x5x5
SPLINE_ORDER=5
TRANSFORMTYPE='b'
HISTOGRAM_MATCHING=1
THREAD_NUMBER=16

#Trans Parms

#JLF Parms
JOINT_ALPHA=1
JOINT_BETA=2
LABEL_OUT_PREFIX="seg_${JOINT_ALPHA}_${JOINT_BETA}"
CASE_DIRS=`ls -l --time-style="long-iso" ${CASE_ROOT_DIR}  | egrep '^d' | awk '{print $8}'`
OUTPUTPATH="${ROOT_PATH}/GridOutput/"


#SUB FOLDERS
MASK_DIR="DilatedMask"
SMOOTHED_MASK_DIR="SmoothedMask"
N4IMG_DIR="N4Img"
SUSAN_DIR="SUSAN"
LAP_DIR="Laplacian"

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

for CASE_DIR in ${CASE_DIRS}
do
	INPUTPATH="${CASE_ROOT_DIR}/${CASE_DIR}"
	MANUAL_LABEL_DIR="${INPUTPATH}/Manual"

	TRAN_JOB_NAME_PREFIX="${PROJECT_JOB_NAME}_${CASE_DIR}_T"
	FUSION_JOB_NAME="${PROJECT_JOB_NAME}_${CASE_DIR}_F"
	
	OUT_DIR="${OUT_ROOT_DIR}/${CASE_DIR}"
	TRANPATH="${OUT_DIR}/${TRAN_SUB_DIR}/"
	WARPPATH="${OUT_DIR}/${WARP_SUB_DIR}/"

	# Target Images
	FIXED_IMG="${TEMPLATE_INPUT}/${CASE_DIR}/avg${TEMPLATE_ITERATION}.nii.gz"
	# FIXED_SMOOTHED_MASK="${TEMPLATE_INPUT}/${CASE_DIR}/msk${i}.nii.gz"
	# FIXED_MASK="${TEMPLATE_INPUT}/${CASE_DIR}/msk${i}.nii.gz"
	# FIXED_SUSAN="${TEMPLATE_INPUT}/${CASE_DIR}/susan${i}.nii.gz"
	# FIXED_LAP="${TEMPLATE_INPUT}/${CASE_DIR}/lap${i}.nii.gz"

	if [[ ! -d ${MANUAL_LABEL_DIR} ]] || [[ ! -f ${FIXED_IMG} ]];then
		continue;
	fi

	for (( i = 1; i <= ${PHASE_NUMBER}; i++))
	do

	    TRAN_JOB_NAME="${TRAN_JOB_NAME_PREFIX}_p${i}"
	    OUT_TRAN_IMG="${WARPPATH}/seg${i}Warped.nii.gz"
	    # N4Img
    	# MOVING_IMG="${WARPPATH}/N4Img/img${i}.nii.gz"

        # TRAN_PHASE_CMD="${TRAN_CMD} -t ${WARPPATH}/reg${i}1Warp.nii.gz -t ${WARPPATH}/reg${i}0GenericAffine.mat"

        # Smoothed Mask 
		# MOVING_SMOOTHED_MASK="${INPUTPATH}/SmoothedMask/mask${i}.nii.gz"
	
		#Mask
		# MOVING_MASK="${INPUTPATH}/DilatedMask/mask${i}.nii.gz"

		# SUSAN
		# MOVING_SUSAN="${INPUTPATH}/SUSAN/susan${i}.nii.gz"

		# Laplacian
		# MOVING_LAP="${INPUTPATH}/Laplacian/lap${i}.nii.gz"
		INPUT_LABEL="${INPUTPATH}/Manual/seg${i}.nii.gz"

		TRAN_CMD=" -d 3 -f 0 --verbose 1 --float -r ${FIXED_IMG} \
		-i ${INPUT_LABEL} -o ${OUT_TRAN_IMG} -n NearestNeighbor \
		-t ${WARPPATH}/reg${i}1Warp.nii.gz -t ${WARPPATH}/reg${i}0GenericAffine.mat"

        if [[ ! -f "${OUT_TRAN_IMG}" ]] && [[ -f ${INPUT_LABEL} ]];then
			qsubProc "${TRAN_JOB_NAME}" "${ANTSPATH}/antsApplyTransforms ${TRAN_CMD}"
		fi

	done
	  JOINT_LABEL_CMD="-l ${WARPPATH}/seg*Warped.nii.gz -tg ${FIXED_IMG} -g ${WARPPATH}/reg*Warped.nii.gz
	  -p ${OUT_DIR}/${LABEL_OUT_PREFIX}_p%04d.nii.gz
	  -m Joint[${JOINT_ALPHA},${JOINT_BETA}]
	  ${OUT_DIR}/${LABEL_OUT_PREFIX}.nii.gz "	
    if [[ ! -f "${OUT_DIR}/${LABEL_OUT_PREFIX}.nii.gz" ]] && [[ -f ${FIXED_IMG} ]];then
		qsubProcHold "${TRAN_JOB_NAME_PREFIX}*" "${FUSION_JOB_NAME}" "${ANTSPATH}/jointfusion 3 1 ${JOINT_LABEL_CMD}"
	fi

	echo "${CASE_DIR}"
done