#!/bin/bash
# Auto masking to a target via multi-atlas

VERSION="0.0.2"

start_timeStamp=$(date +"%s")

INPUTPATH='/media/yuhuachen/Document/WorkingData/4DCMRA/AutoMask/MaskData' 
ATLASSIZE=10
REGISTRATIONFLAG=1
FIXEDIMAGE=/media/yuhuachen/Document/WorkingData/4DCMRA/MaskData/img1.nii
TRANSFORMTYPE='b'
LABELFUSION='MajorityVoting'
ORIGINALNUMBEROFTHREADS=${ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS}
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=8

function Help {
    cat <<HELP
Usage:
`basename $0` -i INPUTPATH -t TRANSFORMTYPE -o OUTPUTPATH
Example Case:
`basename $0` -i /media/yuhuachen/Document/WorkingData/4DCMRA/AutoMask -t a -o temp
Compulsory arguments:
	   -i:  INPUT PATH: path of all atlas images
     -f:  FIXED IMAGE: target image
     -o:  Output Path: path of all output files
     -s:  atlas size: total number of images (default = 10)
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
while getopts "h:f:t:i:o:s:l:r:" OPT
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
      f) # Fixed image
   FIXEDIMAGE=$OPTARG
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
if [ -z "$OUTPUTPATH" ]; then
  OUTPUTPATH="${INPUTPATH}/Output"
fi

# Make output directories
if [[ ! -d "$OUTPUTPATH" ]];then
  mkdir $OUTPUTPATH -p
  echo "${OUTPUTPATH} has been made."  
fi
LABLE_STR=""
ATLAS_STR=""

for (( i = 1; i <=$ATLASSIZE; i++)) 
	do
    #Candidates generation
  	# Registration
    if [[ "$REGISTRATIONFLAG" -eq 1 ]];then
     antsRegistrationSyNQuickDownSampledFactor2.sh -t "$TRANSFORMTYPE" -n 8 -d 3 -x $INPUTPATH/sumMask.nii -f $FIXEDIMAGE -m $INPUTPATH/img"$i".nii -o $OUTPUTPATH/"reg${i}"
   fi
    if [[ "$TRANSFORMTYPE"  == "a" ]] || [[ "$TRANSFORMTYPE" == "r" ]] || [[ "$TRANSFORMTYPE" == "t" ]];
      then
        # Affine Transform
        # Transform label
        antsApplyTransforms -d 3 -f 0  --float -i $INPUTPATH/mask"$i".nii -o $OUTPUTPATH/"cand${i}.nii" -r $FIXEDIMAGE -n NearestNeighbor  -t $OUTPUTPATH/"reg${i}"0GenericAffine.mat
        # Transform image
        antsApplyTransforms -d 3 -f 0 -i $INPUTPATH/img"$i".nii -o $OUTPUTPATH/img"$i".nii -r $FIXEDIMAGE -t $OUTPUTPATH/"reg${i}"0GenericAffine.mat
      else
        # Deformable Transform
        # Transform label
        antsApplyTransforms -d 3 -f 0  --float -i $INPUTPATH/mask"$i".nii -o $OUTPUTPATH/cand"$i".nii -r $FIXEDIMAGE -n NearestNeighbor  -t $OUTPUTPATH/"reg${i}"1Warp.nii.gz -t $OUTPUTPATH/"reg${i}"0GenericAffine.mat
        # Transform image
        antsApplyTransforms -d 3 -f 0 -i $INPUTPATH/img"$i".nii -o $OUTPUTPATH/img"$i".nii -r $FIXEDIMAGE -t $OUTPUTPATH/"reg${i}"1Warp.nii.gz -t $OUTPUTPATH/"reg${i}"0GenericAffine.mat
    fi     
    LABLE_STR="${LABLE_STR} ${OUTPUTPATH}/cand${i}.nii"    
    ATLAS_STR="${ATLAS_STR} ${OUTPUTPATH}/img${i}.nii"    
done
# Label Fusion
case $LABELFUSION in
  "MajorityVoting")
   ImageMath 3 "${OUTPUTPATH}/automask".nii MajorityVoting $LABLE_STR
    ;;
  "JointFusion")
   jointfusion 3 1 -l $LABEL_STR -g $ATLAS_STR -tg $FIXEDIMAGE "${OUTPUTPATH}/automask.nii" 
    ;;
  "JointFusion2D")
   jointfusion 3 1 -l $LABEL_STR -g $ATLAS_STR -tg $FIXEDIMAGE -rp 2x2x1 -rs 3x3x1 "${OUTPUTPATH}/automask.nii"
    ;;  
  "STAPLE")
   ImageMath 3 "${OUTPUTPATH}/STAPLE".nii STAPLE 0.75 $LABEL_STR
   ImageMath 3 "${OUTPUTPATH}/automask".nii ReplaceVoxelValue "${OUTPUTPATH}/STAPLE0001".nii 0.5 1 1
   ImageMath 3 "${OUTPUTPATH}/automask".nii ReplaceVoxelValue "${OUTPUTPATH}/automask".nii 0 0.5 0
   rm "${OUTPUTPATH}/STAPLE0001".nii
    ;;
  "Spatial")
   ImageMath 3 "${OUTPUTPATH}/automask".nii CorrelationVoting $FIXEDIMAGE $ALTAS_STR  $LABEL_STR
    ;;
esac

#Timing
end_timeStamp=$(date +"%s")
diff=$(($end_timeStamp-$start_timeStamp))
echo "$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed."
# Save timing text file.
echo "$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed.">>"${OUTPUTPATH}/Time_${LABELFUSION}.txt"
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$ORIGINALNUMBEROFTHREADS
