#!/bin/bash

if [[ -z ${ANTSPATH} ]];then
  export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"
fi
if [[ -z ${FSLDIR} ]];then
  export FSLDIR="/hpc/apps/fsl/5.0.4/"
fi

if [[ ${#} -lt 1 ]];then
  echo "Usage ${0} CASE_FOLDER e.g case_1253"
  exit -1
fi
CASE_DIR=${1}
CODE_NAME=O5D5X
ITERATION=5
ROOT_PATH="/hpc/home/pangjx/4DCMRA/Data/"
INPUTPATH="${ROOT_PATH}/Cases/${CASE_DIR}/"
OUTPUTPATH="${ROOT_PATH}/Templates/${CASE_DIR}/"

PROJECT_JOB_NAME="TEMP_${CODE_NAME}_${CASE_DIR}"

REGISTRATION_SCRIPT="../RegScripts/BSyN_metric0.sh"
SPLINE_DISTANCE="5x5x5"
TRANSFORMTYPE='b'
HISTOGRAM_MATCHING=1
THREAD_NUMBER=16

PHASENUMBER=16
REGISTRATIONFLAG=1

#Preprocessing
# SUSAN Parms
BT=35
DT=2

# Lap Parms
LAP_RADIUS=2

#SUB FOLDERS
MASK_DIR="DilatedMask"
SMOOTHED_MASK_DIR="SmoothedMask"
N4IMG_DIR="N4Img"
SUSAN_DIR="SUSAN"
LAP_DIR="Laplacian"

GRID_OUTPUTPATH="${ROOT_PATH}/GridOutput/"
function Help {
    cat <<HELP
Usage:
`basename $0` -i INPUTPATH -t TRANSFORMTYPE -o OUTPUTPATH -e ITERATION -p Job name
Example Case:
`basename $0` -i /media/yuhuachen/Document/WorkingData/4DCMRA/AutoMask -t a -o temp -e 5
Compulsory arguments:
     -e:  Iteration to form a template (default = 5)
	   -i:  INPUT PATH: path of input images
     -o:  Output Path: path of all output files
     -p:  Project Job Name (default = TEM)
     -s:  Phase Number: total number of phase (default = 16)
     -r:  Registration On/Off: 1 On, 0 Off (default = 1)    
     -t:  transform type (default = 'a')
        t: translation
        r: rigid
        a: rigid + affine
        s: rigid + affine + deformable syn
        sr: rigid + deformable syn
        b: rigid + affine + deformable b-spline syn
        br: rigid + deformable b-spline syn
--------------------------------------------------------------------------------------
script by Yuhua Chen 8/11/2015
--------------------------------------------------------------------------------------
HELP
    exit 1
}

if [[ "$1" == "-h" || $# -eq 0 ]];
  then
    Help >&2
  fi
#Input Parms
while getopts "h:e:r:s:t:i:o:p:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
   ;;
      t) # transform type
   TRANSFORMTYPE=$OPTARG
   ;;
      r) # Registration Switch
    REGISTRATIONFLAG=$OPTARG
    ;;
      s) # Phase Number
   PHASENUMBER=$OPTARG
   ;;
      i) # Input path
   INPUTPATH=$OPTARG
   ;;
      e) # Number of iteration
    ITERATION=$OPTARG
    ;;
   	  o) # Output path
   OUTPUTPATH=$OPTARG
   ;;
      p) # Output path
   PROJECT_JOB_NAME=$OPTARG
   ;;   
     \?) # getopts issues an error message
   echo "$USAGE" >&2
   exit 1
   ;;
  esac
done

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

function ComputeAvgImage(){
	# Require Input: the number of iteration	
	# Construct Average Image
  FIXED_IMG="${WARPPATH}/avg${i}.nii.gz"
  FIXED_MASK="${WARPPATH}/msk${i}.nii.gz"
  PREPRO_JOB_PREFIX="${PROJECT_JOB_NAME}_Iter${i}_PRE"  
  LAST_ITER=$((${i}-1))
	avgImgStr=" "
	# for (( p = 1; p <= $PHASENUMBER; p++))
	# do
	# 	if [[ "$1" -eq 0 ]]; then
	# 		avgImgStr+=" ${INPUTPATH}/phase${p}.nii"
	# 	else
	# 		avgImgStr+=" ${OUTPUTPATH}/${1}/reg${p}Warped.nii"
	# 	fi		
	# done
  if [[ "${i}" -eq 0 ]];then
    avgImgStr="${INPUTPATH}/${N4IMG_DIR}/img*.nii.gz"
  else
    avgImgStr="${WARPPATH}/Iter${LAST_ITER}/reg*Warped.nii.gz"
  fi

  if [[ "${i}" -eq 0 ]];then
    avgMskStr="${INPUTPATH}/${MASK_DIR}/mask*.nii.gz"
  else
    avgMskStr="${WARPPATH}/Iter${LAST_ITER}/msk*Warped.nii.gz"
  fi


  AVGIMG_JOB_NAME="${PREPRO_JOB_PREFIX}_AVGIMG"
  AVGMSK_JOB_NAME="${PREPRO_JOB_PREFIX}_AVGMSK"

  #Average the images
  if [[ ! -f ${FIXED_IMG} ]];then
    qsubProcHold "${PROJECT_JOB_NAME}_Iter${LAST_ITER}*" "${AVGIMG_JOB_NAME}" "${ANTSPATH}/AverageImages 3 ${FIXED_IMG} 1 ${avgImgStr}"
  fi
  #Average the masks
  if [[ ! -f ${FIXED_MASK} ]];then
    qsubProcHold "${PROJECT_JOB_NAME}_Iter${LAST_ITER}*" "${AVGMSK_JOB_NAME}" "${ANTSPATH}/AverageImages 3 ${FIXED_MASK} 1 ${avgMskStr}"
  fi

  #Preprocessing
  #SUSAN
  FIXED_SUSAN="${WARPPATH}/susan${i}.nii.gz"
  SUSAN_JOB_NAME="${PREPRO_JOB_PREFIX}_SUSAN"

  if [[ ! -f ${FIXED_SUSAN} ]];then
    SUSANCMD=" ${FIXED_IMG} ${BT} ${DT} 3 1 0 ${FIXED_SUSAN} "
    qsubProcHold ${AVGIMG_JOB_NAME} "${SUSAN_JOB_NAME}" "${FSLDIR}/bin/susan ${SUSANCMD}"
  fi

  #Laplacian
  FIXED_LAP="${WARPPATH}/lap${i}.nii.gz"
  LAP_JOB_NAME="${PREPRO_JOB_PREFIX}_LAP"
  
  if [[ ! -f ${FIXED_LAP} ]];then 
    LAPCMD=" 3 ${FIXED_LAP} Laplacian ${FIXED_SUSAN} ${LAP_RADIUS} 1"
  
    qsubProcHold ${SUSAN_JOB_NAME} "${LAP_JOB_NAME}" "${ANTSPATH}/ImageMath ${LAPCMD}"
  fi
}

WARPPATH=${OUTPUTPATH}
mkdir -p $OUTPUTPATH

for (( i = 0; i < ITERATION; i++ ))
do
  mkdir -p "${WARPPATH}/Iter${i}"	
	ComputeAvgImage
	#Registration to the average image
	for (( p = 1; p <= $PHASENUMBER; p++))
	do
      REG_JOB_NAME="${PROJECT_JOB_NAME}_Iter${i}_REG${p}"
      TRAN_JOB_PREFIX="${PROJECT_JOB_NAME}_Iter${i}_TRAN${p}"

      MOVING_IMG="${INPUTPATH}/${N4IMG_DIR}/img${p}.nii.gz"

      OUTPUT_PREFIX="${WARPPATH}/Iter${i}/reg${p}"

      REG_CMD=" -d 3 -t ${TRANSFORMTYPE} -n ${THREAD_NUMBER} -j ${HISTOGRAM_MATCHING} \
       -f ${FIXED_IMG} -m ${MOVING_IMG} -o ${OUTPUT_PREFIX} -s ${SPLINE_DISTANCE}"

      #Mask
      MOVING_MASK="${INPUTPATH}/${MASK_DIR}/mask${p}.nii.gz"
      REG_CMD="${REG_CMD} -f ${FIXED_MASK} -m ${MOVING_MASK} "
      REG_CMD="${REG_CMD} -x[${FIXED_MASK},${MOVING_MASK}]"   

      # SUSAN
      MOVING_SUSAN="${INPUTPATH}/SUSAN/susan${p}.nii.gz"
      REG_CMD="${REG_CMD} -f ${FIXED_SUSAN} -m ${MOVING_SUSAN} "    

      # Laplacian
      MOVING_LAP="${INPUTPATH}/Laplacian/lap${p}.nii.gz"
      REG_CMD="${REG_CMD} -f ${FIXED_LAP} -m ${MOVING_LAP} "    

      #REGISTRATION
      if [[ ! -f "${OUTPUT_PREFIX}0GenericAffine.mat" ]]&& [[ ${REGISTRATIONFLAG} -eq 1 ]];then
        qsubProcHold "${PREPRO_JOB_PREFIX}*" "${REG_JOB_NAME}" "${REGISTRATION_SCRIPT} ${REG_CMD}"
      fi

      #Transform
      TRAN_CMD=" -d 3 -f 0 --verbose 1 --float -r ${FIXED_IMG} \
      -t ${OUTPUT_PREFIX}1Warp.nii.gz -t ${OUTPUT_PREFIX}0GenericAffine.mat"
      # Mask
      WARPED_MASK="${WARPPATH}/Iter${i}/msk${p}Warped.nii.gz"
      if [[ ! -f ${WARPED_MASK} ]];then
        TRAN_CMD_MASK=" ${TRAN_CMD} -i ${MOVING_MASK} -o ${WARPED_MASK} -n NearestNeighbor"
        qsubProcHold ${REG_JOB_NAME} "${TRAN_JOB_PREFIX}_MASK" "${ANTSPATH}/antsApplyTransforms ${TRAN_CMD_MASK}"
      fi
      # Image
      WARPED_IMG="${WARPPATH}/Iter${i}/msk${p}Warped.nii.gz"
      if [[ ! -f ${WARPED_IMG} ]];then
        TRAN_CMD_IMG=" ${TRAN_CMD} -i ${MOVING_IMG} -o ${WARPED_IMG} -n Linear"
        qsubProcHold ${REG_JOB_NAME} "${TRAN_JOB_PREFIX}_IMG" "${ANTSPATH}/antsApplyTransforms ${TRAN_CMD_IMG}"
      fi
	done
done
ComputeAvgImage
