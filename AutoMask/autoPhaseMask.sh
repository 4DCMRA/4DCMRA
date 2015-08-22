#!/bin/bash
# Leave-one-out auto masking

export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"
ROOT_PATH="/hpc/home/pangjx/4DCMRA/Data"

VERSIO="0.2.0"
# Last Update:
# June 19: Now it won't perform any operation if the output file exists to save time
# Using .gz to save space
# Using warped image, no need to transform twice

REGISTRATION_SCRIPT="../RegScripts/autoMask_metric0.sh"

INPUTPATH="$ROOT_PATH/AutoMask/MaskData/"
PROJECT_JOB_NAME="GENX_"
CASE_ROOT_DIR="$ROOT_PATH/MOCO/"
SUSAN_PATH=""
LAPLACIAN_PATH=""

REGISTRATIONFLAG=1
ATLASSIZE=10
PHASE_NUMBER=16
TRANSFORMTYPE='s'
LABELFUSION='MajorityVoting'
MASK_PATH=1
THREAD_NUMBER=8
HISTOGRAM_MATCHING=0

function Help {
    cat <<HELP
Usage:
`basename $0` -i INPUTPATH -t TRANSFORMTYPE -o OUTPUTPATH
Example Case:
`basename $0` -i /media/yuhuachen/Document/WorkingData/4DCMRA/AutoMask -t a -o temp
Compulsory arguments:
     -i:  INPUT PATH: path of input images
     -s:  Atlas Size: total number of images (default = 10)
     -c:  Root diretory of all cases folders
     -u:  Phase Number (default = 16)
     -x:  Mask Path: 1 to use the input path default=1
     -r:  Registration On/Off: 1 On, 0 Off (default = 1)
     -m:  Registration Scripts
     -n:  Thread to be used (default = 8)
     -p:  Project Job Name
     -j:  Histogram Matching 0/1 (default = 0)
     -t:  transform type (default = 's')
        t: translation
        r: rigid
        a: rigid + affine
        s: rigid + affine + deformable syn
        sr: rigid + deformable syn
        b: rigid + affine + deformable b-spline syn
        br: rigid + deformable b-spline syn
--------------------------------------------------------------------------------------
script by Yuhua Chen 7/31/2015
--------------------------------------------------------------------------------------
HELP
    exit 1
}

if [[ "$1" == "-h" || $# -eq 0 ]];
  then
    Help >&2
  fi
#Input Parms
while getopts "h:c:t:r:w:s:i:j:u:m:n:x:p:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
   ;;
      c) # Cases Root Diretory
   CASE_ROOT_DIR=$OPTARG
   ;;
      t) # transform type
   TRANSFORMTYPE=$OPTARG
   ;;
      r) # Registration Switch
    REGISTRATIONFLAG=$OPTARG
    ;;
      w) # Warping Path
    WARPPATH=$OPTARG
    ;;
      s) # atlas size
   ATLASSIZE=$OPTARG
   ;;
      i) # Input path
   INPUTPATH=$OPTARG
   ;;
      j) # Histogram Matching
   HISTOGRAM_MATCHING=$OPTARG
   ;;
      u) # Phase Number
   PHASE_NUMBER=$OPTARG
   ;;
      m) # Number of threads
   REGISTRATION_SCRIPT=$OPTARG
   ;;   
      n) # Number of threads
   THREAD_NUMBER=$OPTARG
   ;;
      x) # Mask Path
   MASK_PATH=$OPTARG
   ;;
      p) # Job Name
   PROJECT_JOB_NAME=$OPTARG
   ;;   
     \?) # getopts issues an error message
   echo "$USAGE" >&2
   exit 1
   ;;
  esac
done


function qsubProc(){
  ## 1: Job name
  ## 2: commands
  qsub -cwd -j y -o "${OUTPUTPATH}" -N ${1} ../wrapper.sh ${2}
}

function qsubProcHold(){
  ## 1: Job name
  ## 2: commands
  qsub -cwd -j y -o "${OUTPUTPATH}" -hold_jid ${1} -N ${2} ../wrapper.sh ${3}
}

if [[ ${MASK_PATH} -eq 1 ]]; then
  MASK_PATH=${INPUTPATH}
else
  if [[ ${MASK_PATH} -eq 0 ]];then
    MASK_PATH=""
  fi
fi

CASE_DIRS=`ls -l --time-style="long-iso" ${CASE_ROOT_DIR}  | egrep '^d' | awk '{print $8}'`

for CASE_DIR in ${CASE_DIRS}
do
  REG_JOB_NAME_PREFIX="${PROJECT_JOB_NAME}_${CASE_DIR}_R"
  TRAN_JOB_NAME_PREFIX="${PROJECT_JOB_NAME}_${CASE_DIR}_T"
  FUSION_JOB_NAME_PREFIX="${PROJECT_JOB_NAME}_${CASE_DIR}_F"
  
  OUTPUTPATH="${CASE_ROOT_DIR}/${CASE_DIR}/WholeHeartMask/"
  WARPPATH="${OUTPUTPATH}/WARP/"

  # Make output directories
  if [[ ! -d $OUTPUTPATH ]]; then
    mkdir $OUTPUTPATH -p
    echo "${OUTPUTPATH} has been made."  
  fi
  if [[ ! -d $WARPPATH ]]; then
    mkdir $WARPPATH
    echo "${WARPPATH} has been made."  
  fi  
  for (( target = 1; target <=$PHASE_NUMBER; target++ ))
    do
      LABEL_STR=""

      FIXED_IMG="${CASE_ROOT_DIR}/${CASE_DIR}/phase${target}.nii"
      if [[ -f ${FIXED_IMG} ]];then
        for (( i = 1; i <=$ATLASSIZE; i++)) 
          do
            if [[ "$target" -eq "$i" ]];then
              continue;
            fi
            # Candidates generation
            #************* Register Intensity Image ******************# 
            REG_JOB_NAME="${REG_JOB_NAME_PREFIX}_t${target}_m${i}"
             
            MOVING_IMG="${INPUTPATH}/img${i}.nii"
            MS_IMG="${INPUTPATH}/mask${i}.nii"
            OUTPUT_PREFIX="${WARPPATH}/reg${i}t${target}"

            REG_CMD=" -d 3 -t ${TRANSFORMTYPE} -n ${THREAD_NUMBER} -j ${HISTOGRAM_MATCHING} \
             -f ${FIXED_IMG} -m ${MOVING_IMG} -o ${OUTPUT_PREFIX}"

            if [[ ! -z ${MASK_PATH} ]];then
                FIXED_MASK_IMG="${MASK_PATH}/sumMask.nii"
                MOVING_MASK_IMG="${MASK_PATH}/mask${i}.nii"
                REG_CMD="${REG_CMD} -x [${FIXED_MASK_IMG},${MOVING_MASK_IMG}]"
            fi

            if [[ "$REGISTRATIONFLAG" -eq 1 ]] && [[ ! -f "${OUTPUT_PREFIX}0GenericAffine.mat" ]];then
              if [[ -z ${PRE_JOB_NAME_PREFIX} ]];then
                qsubProc ${REG_JOB_NAME} "${REGISTRATION_SCRIPT} ${REG_CMD}" 
              else
                qsubProcHold "${PRE_JOB_NAME_PREFIX}*" ${REG_JOB_NAME} "${REGISTRATION_SCRIPT} ${REG_CMD}" 
              fi
            fi

            # ***** Translate label ***********#
            TRAN_JOB_NAME="${TRAN_JOB_NAME_PREFIX}_t${target}_m${i}"
            candImg="${WARPPATH}/cand${i}t${target}.nii.gz"

            TRAN_CMD=" -d 3 --float -f 0 -r ${FIXED_IMG} "
            if [[ "$TRANSFORMTYPE"  == "a" ]] || [[ "$TRANSFORMTYPE" == "r" ]] || [[ "$TRANSFORMTYPE" == "t" ]];
            then
              # Affine Transform
              TRAN_CMD="${TRAN_CMD} -t ${OUTPUT_PREFIX}0GenericAffine.mat"
            else
              # Deformable Transform
              TRAN_CMD="${TRAN_CMD} -t ${OUTPUT_PREFIX}1Warp.nii.gz -t ${OUTPUT_PREFIX}0GenericAffine.mat"
            fi

            # Transform labels
            if [[ ! -f ${candImg} ]];then
              TRAN_CMD_LABEL="${TRAN_CMD} -i ${MS_IMG} -o ${candImg} -n NearestNeighbor"
              qsubProcHold ${REG_JOB_NAME} "${TRAN_JOB_NAME}_label" "${ANTSPATH}/antsApplyTransforms ${TRAN_CMD_LABEL}"          
            fi  
            LABEL_STR="${LABEL_STR} ${candImg}  "
        # End of 10 mask atlas loop          
        done

        FUSION_JOB_NAME="${FUSION_JOB_NAME_PREFIX}_t${target}"
        
        # Label Fusion
        SEGMENT_PREFIX=""
        TARGET_IMG=${FIXED_SUSAN}
        case $LABELFUSION in
          "MajorityVoting")
            SEGMENT_PREFIX="mask"
            OUTPUT_MASK="${OUTPUTPATH}/${SEGMENT_PREFIX}${target}.nii.gz"
            if [[ ! -f  ${OUTPUT_MASK} ]];then
             qsubProcHold "${TRAN_JOB_NAME_PREFIX}_t${target}*" ${FUSION_JOB_NAME} "${ANTSPATH}/ImageMath 3 ${OUTPUT_MASK} MajorityVoting $LABEL_STR"
            fi
            ;;
        esac
        echo "${CASE_DIR}:${target}/${ATLASSIZE} Done."
      # End of if FIXED_IMG exists        
      fi
  # End of 16 phases loop      
  done
  PRE_JOB_NAME_PREFIX=${FUSION_JOB_NAME_PREFIX}
# end of all case loop  
done 
