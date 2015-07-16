#!/bin/bash
# Leave-one-out auto masking

export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"
ROOT_PATH="/hpc/home/pangjx/4DCMRA/Data/LV/LOO2/"
PROJECT_JOB_NAME="P3T1"

VERSIO="0.2.0"
# Last Update:
# June 19: Now it won't perform any operation if the output file exists to save time
# Using .gz to save space
# Using warped image, no need to transform twice
#Timing
start_timeStamp=$(date +"%s")
REGISTRATION_SCRIPT="../antsRegistrationSyNPlusAllCC.sh"

INPUTPATH=$ROOT_PATH
REGISTRATIONFLAG=1
ATLASSIZE=7
TRANSFORMTYPE='a'
LABELFUSION='MajorityVoting'
THREAD_NUMBER=16
USINGMASKFLAG=1

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
     -r:  Registration On/Off: 1 On, 0 Off (default = 1)
     -m:  Registration Scripts
     -n:  Thread to be used (default = 8)
     -p:  Project Job Name
     -x:  Mask Flag 0 / 1 (deafult = 1 (Turn on))
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
script by Yuhua Chen 5/30/2015
--------------------------------------------------------------------------------------
HELP
    exit 1
}

if [[ "$1" == "-h" || $# -eq 0 ]];
  then
    Help >&2
  fi
#Input Parms
while getopts "h:t:i:o:s:l:r:w:m:n:p:x:" OPT
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
      m) # Number of threads
   REGISTRATION_SCRIPT=$OPTARG
   ;;   
      n) # Number of threads
   THREAD_NUMBER=$OPTARG
   ;;
      x) # Number of threads
   USINGMASKFLAG=$OPTARG
   ;;
      p) # Output path
   PROJECT_JOB_NAME=$OPTARG
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
for (( target = 1; target <=$ATLASSIZE; target++ ))
  do
    LABEL_STR=""
    ATLAS_STR=""
    for (( i = 1; i <=$ATLASSIZE; i++)) 
    	do
        if [[ "$target" -eq "$i" ]];then
          continue;
        fi
        candImg="${WARPPATH}/cand${i}t${target}.nii.gz"
         # Candidates generation
      	 # Registration
         REG_JOB_NAME="${REG_JOB_NAME_PREFIX}_T${target}_M${i}"
         TRAN_JOB_NAME="${TRAN_JOB_NAME_PREFIX}_T${target}_M${i}"
         if [[ "$REGISTRATIONFLAG" -eq 1 ]] && [[ ! -f "${WARPPATH}/reg${i}t${target}0GenericAffine.mat" ]];then
          if [[ "$USINGMASKFLAG" -eq 1 ]];then
            qsubProc ${REG_JOB_NAME} "${REGISTRATION_SCRIPT} -t ${TRANSFORMTYPE} -n ${THREAD_NUMBER} -d 3 -f ${INPUTPATH}/img${target}.nii.gz -x ${INPUTPATH}/mask${target}.nii.gz -m ${INPUTPATH}/img${i}.nii.gz -o ${WARPPATH}/reg${i}t${target}"
            #qsub -cwd -j y -o "${OUTPUTPATH}" -N "LOO_Reg_T${target}_M${i}" antsRegistrationSyNPlus.sh -t "$TRANSFORMTYPE" -n $THREAD_NUMBER -d 3 -f $INPUTPATH/img"$target".nii.gz -x $INPUTPATH/mask${target}.nii.gz -m $INPUTPATH/img"$i".nii.gz -o $WARPPATH/"reg${i}t${target}"
    	      # ./antsRegistrationSyNPlus.sh -t "$TRANSFORMTYPE" -n $THREAD_NUMBER -d 3 -f $INPUTPATH/img"$target".nii.gz -x $INPUTPATH/mask${target}.nii.gz -m $INPUTPATH/img"$i".nii.gz -o $WARPPATH/"reg${i}t${target}"
           else
            qsubProc ${REG_JOB_NAME} "${REGISTRATION_SCRIPT} -t ${TRANSFORMTYPE} -n ${THREAD_NUMBER} -d 3 -f ${INPUTPATH}/img${target}.nii.gz -m ${INPUTPATH}/img${i}.nii.gz -o ${WARPPATH}/reg${i}t${target}"
            #qsub -cwd -j y -o "${OUTPUTPATH}" -N "LOO_Reg_T${target}_M${i}" antsRegistrationSyNPlus.sh -t "$TRANSFORMTYPE" -n $THREAD_NUMBER -d 3 -f $INPUTPATH/img"$target".nii.gz -m $INPUTPATH/img"$i".nii.gz -o $WARPPATH/"reg${i}t${target}"
            # ./antsRegistrationSyNPlus.sh -t "$TRANSFORMTYPE" -n $THREAD_NUMBER -d 3 -f $INPUTPATH/img"$target".nii.gz -m $INPUTPATH/img"$i".nii.gz -o $WARPPATH/"reg${i}t${target}"
          fi
         fi
         if [[ ! -f ${candImg} ]] ;then
           if [[ "$TRANSFORMTYPE"  == "a" ]] || [[ "$TRANSFORMTYPE" == "r" ]] || [[ "$TRANSFORMTYPE" == "t" ]];
            then
              # Affine Transform
              # Transform label
              qsubProcHold ${REG_JOB_NAME} ${TRAN_JOB_NAME} "${ANTSPATH}/antsApplyTransforms -d 3 --float -f 0 -i ${INPUTPATH}/label${i}.nii.gz -o ${candImg} -r $INPUTPATH/img${target}.nii.gz -n NearestNeighbor  -t ${WARPPATH}/reg${i}t${target}0GenericAffine.mat"
              # qsub -cwd -j y -o "${OUTPUTPATH}" -N "LOO_Trans_T${target}_M${i}" wrapper.sh antsApplyTransforms -d 3 --float -f 0 -i $INPUTPATH/label"$i".nii.gz -o ${candImg} -r $INPUTPATH/img"$target".nii.gz -n NearestNeighbor  -t $WARPPATH/reg"$i"t"$target"0GenericAffine.mat
              # antsApplyTransforms -d 3 --float -f 0 -i $INPUTPATH/label"$i".nii.gz -o ${candImg} -r $INPUTPATH/img"$target".nii.gz -n NearestNeighbor  -t $WARPPATH/reg"$i"t"$target"0GenericAffine.mat
              # Transform image
              # antsApplyTransforms -d 3 --float -f 0 -i $INPUTPATH/img"$i".nii.gz -o $OUTPUTPATH/img"$i"t"$target".nii.gz -r $INPUTPATH/img"$target".nii.gz -t $WARPPATH/reg"$i"t"$target"0GenericAffine.mat
            else
              # Deformable Transform
              # Transform label
              
              qsubProcHold ${REG_JOB_NAME} ${TRAN_JOB_NAME} "${ANTSPATH}/antsApplyTransforms -d 3 --float -f 0 -i ${INPUTPATH}/label${i}.nii.gz -o ${candImg} -r $INPUTPATH/img${target}.nii.gz -n NearestNeighbor  -t $WARPPATH/reg${i}t${target}1Warp.nii.gz -t ${WARPPATH}/reg${i}t${target}0GenericAffine.mat"
              # qsub -cwd -j y -o "${OUTPUTPATH}" -N "LOO_Trans_T${target}_M${i}" wrapper.sh antsApplyTransforms -d 3 --float -f 0 -i $INPUTPATH/label"$i".nii.gz -o ${candImg} -r $INPUTPATH/img"$target".nii.gz -n NearestNeighbor  -t $WARPPATH/reg"$i"t"$target"1Warp.nii.gz -t $WARPPATH/reg"$i"t"$target"0GenericAffine.mat
              # antsApplyTransforms -d 3 --float -f 0 -i $INPUTPATH/label"$i".nii.gz -o ${candImg} -r $INPUTPATH/img"$target".nii.gz -n NearestNeighbor  -t $WARPPATH/reg"$i"t"$target"1Warp.nii.gz -t $WARPPATH/reg"$i"t"$target"0GenericAffine.mat
              # Transform image
              # antsApplyTransforms -d 3 --float -f 0 -i $INPUTPATH/img"$i".nii.gz -o $OUTPUTPATH/img"$i"t"$target".nii.gz -r $INPUTPATH/img"$target".nii.gz -t $WARPPATH/reg"$i"t"$target"1Warp.nii.gz -t $WARPPATH/reg"$i"t"$target"0GenericAffine.mat
          fi
        fi           
        LABEL_STR="${LABEL_STR} ${candImg}  "  
        ATLAS_STR="${ATLAS_STR} ${WARPPATH}/reg${i}t${target}Warped.nii.gz "    
    done

    FUSION_JOB_NAME="${FUSION_JOB_NAME_PREFIX}_T${target}"

    # Label Fusion
    case $LABELFUSION in
      "MajorityVoting")
        if [[ ! -f "${OUTPUTPATH}/voting${target}.nii.gz" ]];then
         qsubProcHold "${TRAN_JOB_NAME_PREFIX}_T${target}*" ${FUSION_JOB_NAME} "${ANTSPATH}/ImageMath 3 ${OUTPUTPATH}/voting${target}.nii.gz MajorityVoting $LABEL_STR"
        fi
        ;;
      "JointFusion")
        if [[ ! -f "${OUTPUTPATH}/joint${target}.nii.gz" ]];then
          qsubProcHold "${TRAN_JOB_NAME_PREFIX}_T${target}*" ${FUSION_JOB_NAME} "${ANTSPATH}/jointfusion 3 1 -l ${LABEL_STR} -g ${ATLAS_STR} -tg ${INPUTPATH}/img${target}.nii.gz ${OUTPUTPATH}/joint${target}.nii.gz"
          # SmoothImage 3 "${OUTPUTPATH}/joint${target}.nii.gz" 3 "${OUTPUTPATH}/joint${target}.nii.gz" 1 1  
        fi
        ;;
      "JointFusion2D")
        if [[ ! -f "${OUTPUTPATH}/joint2d${target}.nii.gz" ]];then
          qsubProcHold "${TRAN_JOB_NAME_PREFIX}_T${target}*" ${FUSION_JOB_NAME}  "${ANTSPATH}/jointfusion 3 1 -l ${LABEL_STR} -g ${ATLAS_STR} -tg ${INPUTPATH}/img${target}.nii.gz -rp 2x2x1 -rs 3x3x1 ${OUTPUTPATH}/joint2d${target}.nii.gz"
          # SmoothImage 3 "${OUTPUTPATH}/joint2d${target}.nii.gz" 3 "${OUTPUTPATH}/joint2d${target}.nii.gz" 1 1  
        fi
        ;;  
      "STAPLE")
        if [[ ! -f "${OUTPUTPATH}/STAPLE${target}.nii.gz" ]];then
         ImageMath 3 "${OUTPUTPATH}/STAPLE${target}".nii.gz STAPLE 0.75 $LABEL_STR
         ImageMath 3 "${OUTPUTPATH}/STAPLE${target}".nii.gz ReplaceVoxelValue "${OUTPUTPATH}/STAPLE${target}0001".nii.gz 0.5 1 1
         ImageMath 3 "${OUTPUTPATH}/STAPLE${target}".nii.gz ReplaceVoxelValue "${OUTPUTPATH}/STAPLE${target}".nii.gz 0 0.5 0
         rm "${OUTPUTPATH}/STAPLE${target}0001".nii.gz
        fi
        ;;
      "Spatial")
        if [[ ! -f "${OUTPUTPATH}/Spatial${target}".nii.gz ]];then
          qsubProcHold "${TRAN_JOB_NAME_PREFIX}_T${target}*" ${FUSION_JOB_NAME}  "LOO_Fusion_T${target}" "ImageMath 3 ${OUTPUTPATH}/Spatial${target}.nii.gz CorrelationVoting ${INPUTPATH}/img${target}.nii.gz ${ALTAS_STR}  ${LABEL_STR}"
          # SmoothImage 3 "${OUTPUTPATH}/Spatial${target}.nii.gz" 4 "${OUTPUTPATH}/Spatial${target}.nii.gz" 1 1  
        fi
        ;;
    esac
    echo "${target}/${ATLASSIZE} Done."
done
#Timing
# end_timeStamp=$(date +"%s")
# diff=$(($end_timeStamp-$start_timeStamp))
# echo "$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed."
# # Save timing text file.
# echo "$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed.">>"${OUTPUTPATH}/Time_${LABELFUSION}.txt"
#ITK Threads
