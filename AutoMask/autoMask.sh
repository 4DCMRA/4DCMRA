#!/bin/bash
# Auto masking via multi-atlas

VERSION="0.0.1"

INPUTPATH=/media/yuhuachen/Document/WorkingData/4DCMRA/MaskData
ATLASSIZE=6
TRANSFORMTYPE='a'
LABELFUSION='MajorityVoting'

function Help {
    cat <<HELP
Usage:
`basename $0` -i INPUTPATH -t TRANSFORMTYPE -o OUTPUTPATH
Example Case:
`basename $0` -i /media/yuhuachen/Document/WorkingData/4DCMRA/AutoMask -t a -o temp
Compulsory arguments:
	   -i:  INPUT PATH: path of input images
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
script by Yuhua Chen
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
for (( target = 1; target <=$ATLASSIZE; target++ ))
  do
    LABEL_STR=""
    ATLAS_STR=""

    for (( i = 1; i <=$ATLASSIZE; i++)) 
    	do
        if [[ "$target" -eq "$i" ]];then
          continue;
        fi
        #Candidates generation
      	# Registration
      	antsRegistrationSyNQuick.sh -t "$TRANSFORMTYPE" -n 8 -d 3 -f $INPUTPATH/img"$target".nii -m $INPUTPATH/img"$i".nii -o $OUTPUTPATH/"reg"$i"t"$target
      	if [[ "$TRANSFORMTYPE"  == "a" ]] || [[ "$TRANSFORMTYPE" == "r" ]] || [[ "$TRANSFORMTYPE" == "t" ]];
      		then
            # Affine Transform
      			# Transform label
      			antsApplyTransforms -d 3 -f 0 -i $INPUTPATH/mask"$i".nii -o $OUTPUTPATH/cand"$i"t"$target".nii -r $INPUTPATH/img"$target".nii -n NearestNeighbor  -t $OUTPUTPATH/reg"$i"t"$target"0GenericAffine.mat
      			# Transform image
      			antsApplyTransforms -d 3 -f 0 -i $INPUTPATH/img"$i".nii -o $OUTPUTPATH/img"$i"t"$target".nii -r $INPUTPATH/img"$target".nii -t $OUTPUTPATH/reg"$i"t"$target"0GenericAffine.mat
      		else
            # Deformable Transform
      			# Transform label
      			antsApplyTransforms -d 3 -f 0 -i $INPUTPATH/mask"$i".nii -o $OUTPUTPATH/cand"$i"t"$target".nii -r $INPUTPATH/img"$target".nii -n NearestNeighbor  -t $OUTPUTPATH/reg"$i"t"$target"1Warp.nii.gz -t $OUTPUTPATH/reg"$i"t"$target"0GenericAffine.mat
      			# Transform image
      			antsApplyTransforms -d 3 -f 0 -i $INPUTPATH/img"$i".nii -o $OUTPUTPATH/img"$i"t"$target".nii -r $INPUTPATH/img"$target".nii -t $OUTPUTPATH/reg"$i"t"$target"1Warp.nii.gz -t $OUTPUTPATH/reg"$i"t"$target"0GenericAffine.mat
      	fi
        LABEL_STR="${LABEL_STR} ${OUTPUTPATH}/cand${i}t${target}.nii"        
    done
    case $LABELFUSION in
      "MajorityVoting")
       ImageMath 3 "${OUTPUTPATH}/voting${target}".nii MajorityVoting $LABEL_STR
        ;;
      "LabelFusion")
        
        ;;
    esac
    echo "${target}/${ATLASSIZE} Done."
done