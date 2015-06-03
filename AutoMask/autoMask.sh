#!/bin/bash
# Leave-one-out auto masking


VERSION="0.1.0"
# Last Update:
# May 30: Now it won't perform any operation if the output file exists to save time
#Timing
start_timeStamp=$(date +"%s")

INPUTPATH=/media/yuhuachen/Document/WorkingData/4DCMRA/MaskData
REGISTRATIONFLAG=1
ATLASSIZE=10
TRANSFORMTYPE='a'
LABELFUSION='MajorityVoting'
USINGMASKFLAG=0

#Threads
ORIGINALNUMBEROFTHREADS=${ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS}
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=8
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
while getopts "h:t:i:o:s:l:r:w:" OPT
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
  mkdir $OUTPUTPATH
  echo "${OUTPUTPATH} has been made."  
fi
if [[ ! -d $WARPPATH ]]; then
  mkdir $WARPPATH
  echo "${WARPPATH} has been made."  
fi

for (( target = 1; target <=$ATLASSIZE; target++ ))
  do
    LABEL_STR=""
    ATLAS_STR=""

    for (( i = 1; i <=$ATLASSIZE; i++)) 
    	do
        if [[ "$target" -eq "$i" ]];then
          continue;
        fi
         # Candidates generation
      	 # Registration
         if [[ "$REGISTRATIONFLAG" -eq 1 ]] && [[ ! -f "${WARPPATH}/reg${i}t${target}0GenericAffine.mat" ]];then
          if [[ "$USINGMASKFLAG" -eq 1 ]];then
    	       antsRegistrationSyNQuickDownSampledFactor2.sh -t "$TRANSFORMTYPE" -n 8 -d 3 -f $INPUTPATH/img"$target".nii -x $INPUTPATH/sumMask.nii -m $INPUTPATH/img"$i".nii -o $WARPPATH/"reg${i}t${target}"
           else
            antsRegistrationSyNQuickDownSampledFactor2.sh -t "$TRANSFORMTYPE" -n 8 -d 3 -f $INPUTPATH/img"$target".nii -m $INPUTPATH/img"$i".nii -o $WARPPATH/"reg${i}t${target}"
          fi
         fi
         if [[ ! -f $OUTPUTPATH/cand"$i"t"$target".nii ]] || [[ ! -f $OUTPUTPATH/img"$i"t"$target".nii ]];then
           if [[ "$TRANSFORMTYPE"  == "a" ]] || [[ "$TRANSFORMTYPE" == "r" ]] || [[ "$TRANSFORMTYPE" == "t" ]];
            then
              # Affine Transform
              # Transform label
              antsApplyTransforms -d 3 --float -f 0 -i $INPUTPATH/mask"$i".nii -o $OUTPUTPATH/cand"$i"t"$target".nii -r $INPUTPATH/img"$target".nii -n NearestNeighbor  -t $WARPPATH/reg"$i"t"$target"0GenericAffine.mat
              # Transform image
              antsApplyTransforms -d 3 --float -f 0 -i $INPUTPATH/img"$i".nii -o $OUTPUTPATH/img"$i"t"$target".nii -r $INPUTPATH/img"$target".nii -t $WARPPATH/reg"$i"t"$target"0GenericAffine.mat
            else
              # Deformable Transform
              # Transform label
              antsApplyTransforms -d 3 --float -f 0 -i $INPUTPATH/mask"$i".nii -o $OUTPUTPATH/cand"$i"t"$target".nii -r $INPUTPATH/img"$target".nii -n NearestNeighbor  -t $WARPPATH/reg"$i"t"$target"1Warp.nii.gz -t $WARPPATH/reg"$i"t"$target"0GenericAffine.mat
              # Transform image
              antsApplyTransforms -d 3 --float -f 0 -i $INPUTPATH/img"$i".nii -o $OUTPUTPATH/img"$i"t"$target".nii -r $INPUTPATH/img"$target".nii -t $WARPPATH/reg"$i"t"$target"1Warp.nii.gz -t $WARPPATH/reg"$i"t"$target"0GenericAffine.mat
          fi
        fi           
        LABEL_STR="${LABEL_STR} ${OUTPUTPATH}/cand${i}t${target}.nii"    
        ATLAS_STR="${ATLAS_STR} ${OUTPUTPATH}/img${i}t${target}.nii"    
    done
    # Label Fusion
    case $LABELFUSION in
      "MajorityVoting")
        if [[ ! -f "${OUTPUTPATH}/voting${target}.nii" ]];then
         ImageMath 3 "${OUTPUTPATH}/voting${target}".nii MajorityVoting $LABEL_STR
        fi
        ;;
      "JointFusion")
        if [[ ! -f "${OUTPUTPATH}/joint${target}.nii" ]];then
          jointfusion 3 1 -l $LABEL_STR -g $ATLAS_STR -tg "${INPUTPATH}/img${target}.nii" "${OUTPUTPATH}/joint${target}.nii" 
        fi
        ;;
      "JointFusion2D")
        if [[ ! -f "${OUTPUTPATH}/joint2d${target}.nii" ]];then
          jointfusion 3 1 -l $LABEL_STR -g $ATLAS_STR -tg "${INPUTPATH}/img${target}.nii" -rp 2x2x1 -rs 3x3x1 "${OUTPUTPATH}/joint2d${target}.nii"
        fi
        ;;  
      "STAPLE")
        if [[ ! -f "${OUTPUTPATH}/STAPLE${target}.nii" ]];then
         ImageMath 3 "${OUTPUTPATH}/STAPLE${target}".nii STAPLE 0.75 $LABEL_STR
         ImageMath 3 "${OUTPUTPATH}/STAPLE${target}".nii ReplaceVoxelValue "${OUTPUTPATH}/STAPLE${target}0001".nii 0.5 1 1
         ImageMath 3 "${OUTPUTPATH}/STAPLE${target}".nii ReplaceVoxelValue "${OUTPUTPATH}/STAPLE${target}".nii 0 0.5 0
         rm "${OUTPUTPATH}/STAPLE${target}0001".nii
        fi
        ;;
      "Spatial")
        if [[ ! -f "${OUTPUTPATH}/Spatial${target}".nii ]];then
          ImageMath 3 "${OUTPUTPATH}/Spatial${target}".nii CorrelationVoting "${INPUTPATH}/img${target}".nii $ALTAS_STR  $LABEL_STR
        fi
        ;;
    esac
    echo "${target}/${ATLASSIZE} Done."
done
#Timing
end_timeStamp=$(date +"%s")
diff=$(($end_timeStamp-$start_timeStamp))
echo "$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed."
# Save timing text file.
echo "$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed.">>"${OUTPUTPATH}/Time_${LABELFUSION}.txt"
#ITK Threads
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$ORIGINALNUMBEROFTHREADS