#!/bin/bash
# Leave-one-out auto masking

export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"
ROOT_PATH="/hpc/home/pangjx/4DCMRA/Data/LV/"
PROJECT_JOB_NAME="P3T1"

VERSIO="0.2.0"
# Last Update:
# June 19: Now it won't perform any operation if the output file exists to save time
# Using .gz to save space
# Using warped image, no need to transform twice
#Timing
start_timeStamp=$(date +"%s")
REGISTRATION_SCRIPT="../antsRegistrationSyNPlusAllCC.sh"

INPUTPATH="$ROOT_PATH/Atlas/Set1"
SUSAN_PATH=""
LAPLACIAN_PATH=""

REGISTRATIONFLAG=1
ATLASSIZE=7
TRANSFORMTYPE='a'
LABELFUSION='MajorityVoting'
THREAD_NUMBER=16
HISTOGRAM_MATCHING=0

function Help {
    cat <<HELP
Usage:
`basename $0` -i INPUTPATH -t TRANSFORMTYPE -o OUTPUTPATH
Example Case:
`basename $0` -i /media/yuhuachen/Document/WorkingData/4DCMRA/AutoMask -t a -o temp
Compulsory arguments:
	   -i:  INPUT PATH: path of input images
     -o:  Output Path: path of all output files
     -s:  Atlas Size: total number of images (default = 10)
     -u:  Manual labels path (default = INPUT PATH)
     -q:  SUSAN_PATH
     -z:  LAPLACIAN_PATH
     -x:  Mask Path: 1 to use the input path or the path of mask images, empty if no masks are applied (default = empty)
     -r:  Registration On/Off: 1 On, 0 Off (default = 1)
     -m:  Registration Scripts
     -n:  Thread to be used (default = 8)
     -p:  Project Job Name
     -j:  Histogram Matching 0/1 (default = 0)
     -l:  Label fusion: label fusion method (default = 'MajorityVoting')
        MajorityVoting: Majority voting
        JointFusion: Joint Label Fusion
        JointFusion2D: 2D Joint Label Fusion
        STAPLE:  STAPLE, AverageLabels
        Spatial: Correlation voting       
     -t:  transform type (default = 'a')
        t: translation
        r: rigid
        a: rigid + affine
        s: rigid + affine + deformable syn
        sr: rigid + deformable syn
        b: rigid + affine + deformable b-spline syn
        br: rigid + deformable b-spline syn
--------------------------------------------------------------------------------------
script by Yuhua Chen 7/22/2015
--------------------------------------------------------------------------------------
HELP
    exit 1
}

if [[ "$1" == "-h" || $# -eq 0 ]];
  then
    Help >&2
  fi
#Input Parms
while getopts "h:t:i:u:o:s:l:r:w:m:n:p:x:j:q:z:" OPT
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
      w) # Warping Path
    WARPPATH=$OPTARG
    ;;
      s) # atlas size
   ATLASSIZE=$OPTARG
   ;;
      i) # Input path
   INPUTPATH=$OPTARG
   ;;
      u) # Manual labels path
   MS_PATH=$OPTARG
   ;;   
      j) # Histogram Matching
   HISTOGRAM_MATCHING=$OPTARG
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
      q) # SUSAN PATH
   SUSAN_PATH=$OPTARG
   ;;
      z) # Lap path
   LAPLACIAN_PATH=$OPTARG
   ;;
      o) # Output path
   OUTPUTPATH=$OPTARG
   ;;
      l) # Label Fusion
   LABELFUSION=$OPTARG
   ;;
     \?) # getopts issues an error message
   echo "$USAGE" >&2
   exit 1
   ;;
  esac
done

# Set up working directories
if [[ -z "$OUTPUTPATH" ]]; then
  OUTPUTPATH="${INPUTPATH}/Output"
fi
if [[ -z "$WARPPATH" ]]; then
  WARPPATH=$OUTPUTPATH
fi

if [[ -z ${MS_PATH} ]]; then
  MS_PATH=${INPUTPATH}
fi
if [[ ${MASK_PATH} -eq 1 ]]; then
  MASK_PATH=${INPUTPATH}
fi

# Make output directories
if [[ ! -d $OUTPUTPATH ]]; then
  mkdir $OUTPUTPATH -p
  echo "${OUTPUTPATH} has been made."  
fi
if [[ ! -d $WARPPATH ]]; then
  mkdir $WARPPATH
  echo "${WARPPATH} has been made."  
fi

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

REG_JOB_NAME_PREFIX="${PROJECT_JOB_NAME}_R"
TRAN_JOB_NAME_PREFIX="${PROJECT_JOB_NAME}_T"
FUSION_JOB_NAME_PREFIX="${PROJECT_JOB_NAME}_F"
VALIDATION_JOB_NAME_PREFIX="${PROJECT_JOB_NAME}_V"

for (( target = 1; target <=$ATLASSIZE; target++ ))
  do
    LABEL_STR=""
    TARGET_MOD_IMGS=""
    WARPED_ORIGIN_IMGS=""
    WARPED_MOD_IMGS=""

    FIXED_IMG="${INPUTPATH}/img${target}.nii.gz"
    
    if [[ ! -z ${SUSAN_PATH} ]]; then
      FIXED_SUSAN="${SUSAN_PATH}/susan${target}.nii.gz"
    fi

    if [[ ! -z ${LAPLACIAN_PATH} ]]; then
      FIXED_LAPLACIAN="${LAPLACIAN_PATH}/lap${target}.nii.gz"
    fi

    for (( i = 1; i <=$ATLASSIZE; i++)) 
    	do
        if [[ "$target" -eq "$i" ]];then
          continue;
        fi
        # Candidates generation
      	#************* Register Intensity Image ******************# 
        REG_JOB_NAME="${REG_JOB_NAME_PREFIX}_t${target}_m${i}"
         
        MOVING_IMG="${INPUTPATH}/img${i}.nii.gz"
        OUTPUT_PREFIX="${WARPPATH}/reg${i}t${target}"

        REG_CMD=" -d 3 -t ${TRANSFORMTYPE} -n ${THREAD_NUMBER} -j ${HISTOGRAM_MATCHING} \
         -f ${FIXED_IMG} -m ${MOVING_IMG} -o ${OUTPUT_PREFIX}"

        if [[ ! -z ${MASK_PATH} ]];then
            FIXED_MASK_IMG="${MASK_PATH}/mask${target}.nii.gz"
            MOVING_MASK_IMG="${MASK_PATH}/mask${i}.nii.gz"
            REG_CMD="${REG_CMD} -x [${FIXED_MASK_IMG},${MOVING_MASK_IMG}]"
            REG_CMD="${REG_CMD} -f ${FIXED_MASK_IMG} -m ${MOVING_MASK_IMG}"
        fi

        # SUSAN
        if [[ ! -z ${SUSAN_PATH} ]]; then
          MOVING_SUSAN="${SUSAN_PATH}/susan${i}.nii.gz"
          REG_CMD="${REG_CMD} -f ${FIXED_SUSAN} -m ${MOVING_SUSAN}"
        fi

        # Laplacian
        if [[ ! -z ${LAPLACIAN_PATH} ]]; then
          MOVING_LAPLACIAN="${LAPLACIAN_PATH}/lap${i}.nii.gz"
          REG_CMD="${REG_CMD} -f ${FIXED_LAPLACIAN} -m ${MOVING_LAPLACIAN}"
        fi

        if [[ "$REGISTRATIONFLAG" -eq 1 ]] && [[ ! -f "${OUTPUT_PREFIX}0GenericAffine.mat" ]];then
            qsubProc ${REG_JOB_NAME} "${REGISTRATION_SCRIPT} ${REG_CMD}" 
        fi

        # ***** Translate label ***********#
        TRAN_JOB_NAME="${TRAN_JOB_NAME_PREFIX}_t${target}_m${i}"
        MS_IMG="${MS_PATH}/label${i}.nii.gz" #Manual Label Image
        candImg="${WARPPATH}/cand${i}t${target}.nii.gz"

          TRAN_CMD=" -d 3 --float -f 0 -r ${FIXED_IMG} "
          if [[ "$TRANSFORMTYPE"  == "a" ]] || [[ "$TRANSFORMTYPE" == "r" ]] || [[ "$TRANSFORMTYPE" == "t" ]];
          then
            # Affine Transform
            TRAN_CMD="${TRAN_CMD} -t ${OUTPUT_PREFIX}0GenericAffine.mat"
#           qsubProcHold ${REG_JOB_NAME} ${TRAN_JOB_NAME} "${ANTSPATH}/antsApplyTransforms -d 3 --float -f 0 -i ${INPUTPATH}/label${i}.nii.gz -o ${candImg} -r $INPUTPATH/img${target}.nii.gz -n NearestNeighbor  -t ${WARPPATH}/reg${i}t${target}0GenericAffine.mat"
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


          # Transform origin images
          WARPED_IMG="${WARPPATH}/reg${i}t${target}Warped.nii.gz"
          if [[ ! -f ${WARPED_IMG} ]]; then
            TRAN_CMD_IMG="${TRAN_CMD} -i ${MOVING_IMG} -o ${WARPED_IMG} -n Linear"
            qsubProcHold ${REG_JOB_NAME} "${TRAN_JOB_NAME}_img" "${ANTSPATH}/antsApplyTransforms ${TRAN_CMD_IMG}"          
          fi
          
          WARPED_ORIGIN_IMGS="${WARPED_ORIGIN_IMGS} ${WARPED_IMG}"
          WARPED_MOD_IMGS="${WARPED_MOD_IMGS} ${WARPED_IMG}"

          # Transform Susan
          if [[ ! -z ${MOVING_SUSAN} ]]; then
            WARPED_SUSAN="${WARPPATH}/susan${i}t${target}.nii.gz"
            if [[ ! -f ${WARPED_SUSAN} ]];then            
              TRAN_CMD_SUSAN="${TRAN_CMD} -i ${MOVING_SUSAN} -o ${WARPED_SUSAN} -n Linear "
              qsubProcHold ${REG_JOB_NAME} "${TRAN_JOB_NAME}_susan" "${ANTSPATH}/antsApplyTransforms ${TRAN_CMD_SUSAN}"          
            fi
            WARPED_MOD_IMGS="${WARPED_MOD_IMGS} ${WARPED_SUSAN}" 
          fi

          # Transform Lapcian
          if [[ ! -z ${MOVING_LAPLACIAN} ]]; then
            WARPED_LAPLACIAN="${WARPPATH}/lap${i}t${target}.nii.gz"
            if [[ ! -f ${WARPED_LAPLACIAN} ]];then
              TRAN_CMD_LAPLACIAN="${TRAN_CMD} -i ${MOVING_LAPLACIAN} -o ${WARPED_LAPLACIAN} -n Linear "
              qsubProcHold ${REG_JOB_NAME} "${TRAN_JOB_NAME}_lap" "${ANTSPATH}/antsApplyTransforms ${TRAN_CMD_LAPLACIAN}"          
            fi
            WARPED_MOD_IMGS="${WARPED_MOD_IMGS} ${WARPED_LAPLACIAN}" 
          fi
    done

    # Target Images for JLF
    TARGET_MOD_IMGS="${TARGET_MOD_IMGS} ${FIXED_IMG}"
    if [[ ! -z ${MOVING_SUSAN} ]]; then
      TARGET_MOD_IMGS="${TARGET_MOD_IMGS} ${FIXED_SUSAN}"
    fi
    if [[ ! -z ${MOVING_SUSAN} ]]; then
      TARGET_MOD_IMGS="${TARGET_MOD_IMGS} ${FIXED_LAPLACIAN}"
    fi


    FUSION_JOB_NAME="${FUSION_JOB_NAME_PREFIX}_t${target}"

    # Label Fusion
    SEGMENT_PREFIX=""
    TARGET_IMG=${FIXED_SUSAN}
    case $LABELFUSION in
      "MajorityVoting")
        SEGMENT_PREFIX="voting"
        if [[ ! -f "${OUTPUTPATH}/${SEGMENT_PREFIX}${target}.nii.gz" ]];then
         qsubProcHold "${TRAN_JOB_NAME_PREFIX}_t${target}*" ${FUSION_JOB_NAME} "${ANTSPATH}/ImageMath 3 ${OUTPUTPATH}/${SEGMENT_PREFIX}${target}.nii.gz MajorityVoting $LABEL_STR"
        fi
        ;;
      "JointFusion")
        SEGMENT_PREFIX="joint"
        if [[ ! -f "${OUTPUTPATH}/${SEGMENT_PREFIX}${target}.nii.gz" ]];then
          JOINT_LABEL_CMD="-l ${LABEL_STR} -tg ${TARGET_MOD_IMGS} -g ${WARPED_MOD_IMGS} 
          -p ${OUTPUTPATH}/${SEGMENT_PREFIX}${target}p%04d.nii.gz
          -m Joint[0.2,2]
          ${OUTPUTPATH}/${SEGMENT_PREFIX}${target}.nii.gz "
          
          JOINT_LABEL_MOD=1
          if [[ ! -z ${SUSAN_PATH} ]]; then
            JOINT_LABEL_MOD=$((${JOINT_LABEL_MOD}+1))
          fi
          if [[ ! -z ${LAPLACIAN_PATH} ]]; then
            JOINT_LABEL_MOD=$((${JOINT_LABEL_MOD}+1))
          fi

          qsubProcHold "${TRAN_JOB_NAME_PREFIX}_t${target}*" ${FUSION_JOB_NAME} "${ANTSPATH}/jointfusion 3 ${JOINT_LABEL_MOD} ${JOINT_LABEL_CMD}"
          
          # SmoothImage 3 "${OUTPUTPATH}/joint${target}.nii.gz" 3 "${OUTPUTPATH}/joint${target}.nii.gz" 1 1  
        fi
        ;;
      "JointFusion2D")
        SEGMENT_PREFIX="joint2d"
        if [[ ! -f "${OUTPUTPATH}/${SEGMENT_PREFIX}${target}.nii.gz" ]];then
          JOINT_LABEL_CMD="-l ${LABEL_STR} -tg ${TARGET_MOD_IMGS} -g ${WARPED_MOD_IMGS} 
          -p ${OUTPUTPATH}/${SEGMENT_PREFIX}${target}p%04d.nii.gz  -rp 2x2x1 -rs 3x3x1
          -m Joint[0.2,2]          
          ${OUTPUTPATH}/${SEGMENT_PREFIX}${target}.nii.gz "
          
          JOINT_LABEL_MOD=1
          if [[ ! -z ${SUSAN_PATH} ]]; then
            JOINT_LABEL_MOD=$((${JOINT_LABEL_MOD}=${JOINT_LABEL_MOD}+1))
          fi
          if [[ ! -z ${LAPLACIAN_PATH} ]]; then
            JOINT_LABEL_MOD=$((${JOINT_LABEL_MOD}=${JOINT_LABEL_MOD}+1))
          fi

          qsubProcHold "${TRAN_JOB_NAME_PREFIX}_t${target}*" ${FUSION_JOB_NAME} "${ANTSPATH}/jointfusion 3 ${JOINT_LABEL_MOD} ${JOINT_LABEL_CMD}"          
          # SmoothImage 3 "${OUTPUTPATH}/joint2d${target}.nii.gz" 3 "${OUTPUTPATH}/joint2d${target}.nii.gz" 1 1  
        fi
        ;;  
      "STAPLE")
        SEGMENT_PREFIX="STAPLE"
        if [[ ! -f "${OUTPUTPATH}/${SEGMENT_PREFIX}${target}.nii.gz" ]];then
         ImageMath 3 "${OUTPUTPATH}/${SEGMENT_PREFIX}${target}".nii.gz STAPLE 0.75 $LABEL_STR
         ImageMath 3 "${OUTPUTPATH}/${SEGMENT_PREFIX}${target}".nii.gz ReplaceVoxelValue "${OUTPUTPATH}/${SEGMENT_PREFIX}${target}0001".nii.gz 0.5 1 1
         ImageMath 3 "${OUTPUTPATH}/${SEGMENT_PREFIX}${target}".nii.gz ReplaceVoxelValue "${OUTPUTPATH}/${SEGMENT_PREFIX}${target}".nii.gz 0 0.5 0
         rm "${OUTPUTPATH}/${SEGMENT_PREFIX}${target}0001".nii.gz
        fi
        ;;
      "Spatial")
        SEGMENT_PREFIX="spatial"
        if [[ ! -f "${OUTPUTPATH}/${SEGMENT_PREFIX}${target}".nii.gz ]];then
          qsubProcHold "${TRAN_JOB_NAME_PREFIX}_t${target}*" ${FUSION_JOB_NAME}  "${ANTSPATH}/ImageMath 3 ${OUTPUTPATH}/${SEGMENT_PREFIX}${target}.nii.gz CorrelationVoting ${TARGET_IMG} ${WARPED_ORIGIN_IMGS}  ${LABEL_STR}"
          # SmoothImage 3 "${OUTPUTPATH}/Spatial${target}.nii.gz" 4 "${OUTPUTPATH}/Spatial${target}.nii.gz" 1 1  
        fi
        ;;
    esac

    echo "${target}/${ATLASSIZE} Done."
done

#Label Overlap
#Registratoin Quality
if [[ "$REGISTRATIONFLAG" -eq 1 ]]; then
  REG_QA_JOB_NAME="${VALIDATION_JOB_NAME_PREFIX}_Candidate"
  REG_QA_CMD="-a ${OUTPUTPATH} -i ${MS_PATH} -o ${OUTPUTPATH}/RegDice/ -s ${ATLASSIZE}"
  qsubProcHold "${REG_JOB_NAME_PREFIX}*" ${REG_QA_JOB_NAME} "../AutoMask/registrationQuality.sh ${REG_QA_CMD}"
fi

if [[ ! -z ${SEGMENT_PREFIX} ]]; then
  VALIDATION_JOB_NAME="${VALIDATION_JOB_NAME_PREFIX}_Seg"
  VALIDATION_CMD="-a ${OUTPUTPATH} -i ${MS_PATH} -o ${OUTPUTPATH}/Dice/ -p ${SEGMENT_PREFIX} -s ${ATLASSIZE}"
  qsubProcHold "${FUSION_JOB_NAME_PREFIX}*" ${VALIDATION_JOB_NAME} "../AutoMask/crossValidation.sh ${VALIDATION_CMD}"
fi
