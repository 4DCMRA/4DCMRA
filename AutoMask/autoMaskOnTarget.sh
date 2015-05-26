#!/bin/bash
# Auto masking via multi-atlas
VERSION="0.0.1"

start_timeStamp=$(date +"%s")

INPUTPATH=/media/yuhuachen/Document/WorkingData/4DCMRA/MaskData
ATLASSIZE=6
FIXEDIMAGE=/media/yuhuachen/Document/WorkingData/4DCMRA/MaskData/img1.nii
TRANSFORMTYPE='a'
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
     -s:  atlas size: total number of images (default = 6)
     -t:  transform type (default = 'a')
        t: translation
        r: rigid
        a: rigid + affine
        s: rigid + affine + deformable syn
        sr: rigid + deformable syn
        b: rigid + affine + deformable b-spline syn
        br: rigid + deformable b-spline syn
--------------------------------------------------------------------------------------
script by Yuhua Chen 5/21/2015
--------------------------------------------------------------------------------------
HELP
    exit 1
}

if [[ "$1" == "-h" || $# -eq 0 ]];
  then
    Help >&2
  fi
#Input Parms
while getopts "h:t:i:o:s:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
   ;;
      t) # transform type
   TRANSFORMTYPE=$OPTARG
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
     \?) # getopts issues an error message
   echo "$USAGE" >&2
   exit 1
   ;;
  esac
done

if [ -z "$OUTPUTPATH" ]; then
  OUTPUTPATH="${INPUTPATH}/Output"
fi
mkdir $OUTPUTPATH
echo "${OUTPUTPATH} has been made."
LABLE_STR=""
ATLAS_STR=""

for (( i = 1; i <=$ATLASSIZE; i++)) 
	do
    #Candidates generation
  	# Registration
  	antsRegistrationSyNQuickDownSampledFactor2.sh -t "$TRANSFORMTYPE" -n 8 -d 3 -f $FIXEDIMAGE -m $INPUTPATH/img"$i".nii -o $OUTPUTPATH/"reg${i}"
  	if [[ "$TRANSFORMTYPE"  == "a" ]] || [[ "$TRANSFORMTYPE" == "r" ]] || [[ "$TRANSFORMTYPE" == "t" ]];
  		then
        # Affine Transform
  			# Transform label
  			antsApplyTransforms -d 3 -f 0 -i $INPUTPATH/mask"$i".nii -o $OUTPUTPATH/"cand${i}.nii" -r $FIXEDIMAGE -n NearestNeighbor  -t $OUTPUTPATH/"reg${i}"0GenericAffine.mat
  			# Transform image
  			antsApplyTransforms -d 3 -f 0 -i $INPUTPATH/img"$i".nii -o $OUTPUTPATH/img"$i".nii -r $FIXEDIMAGE -t $OUTPUTPATH/"reg${i}"0GenericAffine.mat
  		else
        # Deformable Transform
  			# Transform label
  			antsApplyTransforms -d 3 -f 0 -i $INPUTPATH/mask"$i".nii -o $OUTPUTPATH/cand"$i".nii -r $FIXEDIMAGE -n NearestNeighbor  -t $OUTPUTPATH/"reg${i}"1Warp.nii.gz -t $OUTPUTPATH/"reg${i}"0GenericAffine.mat
  			# Transform image
  			antsApplyTransforms -d 3 -f 0 -i $INPUTPATH/img"$i".nii -o $OUTPUTPATH/img"$i".nii -r $FIXEDIMAGE -t $OUTPUTPATH/"reg${i}"1Warp.nii.gz -t $OUTPUTPATH/"reg${i}"0GenericAffine.mat
  	fi
    LABLE_STR="${LABLE_STR} ${OUTPUTPATH}/cand${i}.nii"        
done
case $LABELFUSION in
  "MajorityVoting")
   ImageMath 3 "${OUTPUTPATH}/automask".nii MajorityVoting $LABLE_STR
    ;;
  "LabelFusion")
    
    ;;
esac

#Timing
end_timeStamp=$(date +"%s")
diff=$(($end_timeStamp-$start_timeStamp))
echo "$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed."
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$ORIGINALNUMBEROFTHREADS
