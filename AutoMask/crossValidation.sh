#!/bin/bash
# Cross validation
INPUTPATH=/media/yuhuachen/Document/WorkingData/4DCMRA/MaskData
RESPREF=voting
ATLASSIZE=10
TARGETIMAGE=$INPUTPATH/mask1.nii
start_timeStamp=$(date +"%s")

function Help {
    cat <<HELP
Usage:
`basename $0` -i INPUTPATH -o OUTPUTPATH
Example Case:
`basename $0` -i /media/yuhuachen/Document/WorkingData/4DCMRA/AutoMask -t a -o temp
Compulsory arguments:
     -i:  INPUT PATH: path of ground true images
     -o:  Output Path: path of all test mask files
     -p:  Result Prefix: prefix of the result images (default ='voting')
     	voting : Majority voting
     	joint:	 Joint label fusion
     	joint2:	 2D Joint label fusion
     	STAPLE:  STAPLE, AverageLabels
     	Spatial: Correlation voting
     -s:  atlas size: total number of images (default = 6)
--------------------------------------------------------------------------------------
script by Yuhua Chen 5/26/2015
--------------------------------------------------------------------------------------
HELP
    exit 1
}

if [[ "$1" == "-h" || $# -eq 0 ]];
  then
    Help >&2
  fi
#Input Parms
while getopts "h:t:i:o:s:p:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
   ;;
      s) # atlas size
   ATLASSIZE=$OPTARG
   ;;
   	  p) # Prefix of the result
   RESPREF=$OPTARG
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

for (( i = 1; i <=$ATLASSIZE; i++)) 
  do
  	TARGETIMAGE="${INPUTPATH}/label${i}.nii"
  	ImageMath 3 "${OUTPUTPATH}/Dice_${RESPREF}${i}.txt" DiceAndMinDistSum $TARGETIMAGE "${OUTPUTPATH}/${RESPREF}${i}.nii.gz" "${OUTPUTPATH}/MinDist_${RESPREF}${i}.nii.gz"
    echo "${i}/${ATLASSIZE}"
done

#Timing
end_timeStamp=$(date +"%s")
diff=$(($end_timeStamp-$start_timeStamp))
diff=$(($diff / ${ATLASSIZE}))
echo "$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed."
ITK_GLOBAL_DEFAULT_NUMBER_OF_THREADS=$ORIGINALNUMBEROFTHREADS