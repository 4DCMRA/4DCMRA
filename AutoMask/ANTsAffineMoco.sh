#!/bin/bash
# Motion Correction with ANTs's Affine Registration
# Yuhua Chen
# 5/31/2015


#Timing
start_timeStamp=$(date +"%s")

INPUTPATH='/media/yuhuachen/Document/WorkingData/4DCMRA/Moco/Case7/Nii'
MASKIMG='/media/yuhuachen/Document/WorkingData/4DCMRA/Moco/Case7/Mask/maskAtlas6.nii'
OUTPUTPATH='/media/yuhuachen/Document/WorkingData/4DCMRA/Moco/Case7/Nii/Affine'
# Respiratory phase bins number
RESBINS=5
# Cardiac phase bins number
CARBINS=9

TARGETRES=5
USINGMASKFLAG=1

#ITK Threads
ORIGINALNUMBEROFTHREADS=${ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS}
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=12
function Help {
    cat <<HELP
Usage:
`basename $0` 
Example Case:
`basename $0` 
Compulsory arguments:

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

# Make output directories
if [[ ! -d "$OUTPUTPATH" ]];then
  mkdir $OUTPUTPATH
  echo "${OUTPUTPATH} has been made."  
fi

for (( res = 1; res <=$RESBINS; res++))
do
    if [[ "$res" -eq "$TARGETRES" ]];then
        continue
    fi
    car=4
    # for (( car = 1; car <=$CARBINS; car++))
    # do
        fixImg="${INPUTPATH}/imgc${car}r${TARGETRES}.nii"
        movingImg="${INPUTPATH}/imgc${car}r${res}.nii"
        if [[ "$USINGMASKFLAG" -eq 1 ]];then
            antsRegistrationSyNQuick.sh -t a -n 12 -d 3 -f $fixImg -x $MASKIMG -m $movingImg -o $OUTPUTPATH/"regc${car}r${res}"
        else
            antsRegistrationSyNQuick.sh -t a -n 12 -d 3 -f $fixImg -m $movingImg -o $OUTPUTPATH/"regc${car}r${res}"
        fi
        # Transformation
        antsApplyTransforms -d 3 --float -f 0 -i $movingImg -o "${OUTPUTPATH}/imgc${car}r${res}.nii" -r $fixImg -t $OUTPUTPATH/"regc${car}r${res}"0GenericAffine.mat
    # done
done

#Timing
end_timeStamp=$(date +"%s")
diff=$(($end_timeStamp-$start_timeStamp))
echo "$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed."
# Save timing text file.
echo "$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed.">>"${OUTPUTPATH}/Timing.txt"

#ITK Threads
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$ORIGINALNUMBEROFTHREADS