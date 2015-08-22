#!/bin/bash
if [[ -z ${ANTSPATH} ]];then
  export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"
fi
# Cross validation
INPUTPATH=/media/yuhuachen/Document/WorkingData/4DCMRA/MaskData
ASPATH=/media/yuhuachen/Document/WorkingData/4DCMRA/MaskData
RESPREF=voting
ATLASSIZE=10
start_timeStamp=$(date +"%s")

function Help {
    cat <<HELP 
Usage:
`basename $0` -i INPUTPATH -o OUTPUTPATH
Example Case:
`basename $0` -i /media/yuhuachen/Document/WorkingData/4DCMRA/AutoMask -a AutoSegmentationPath -o OUTPUTPATH
Compulsory arguments:
     -a:  Automatic Segmentation Path
     -e:  Extra Output file
     -i:  INPUT PATH: path of ground true images
     -o:  Output Path: path of all test mask files
     -p:  Result Prefix: prefix of the result images (default ='voting')
     	voting : Majority voting
     	joint:	 Joint label fusion
     	joint2:	 2D Joint label fusion
     	STAPLE:  STAPLE, AverageLabels
     	Spatial: Correlation voting
     -s:  atlas size: total number of images (default = 10)
--------------------------------------------------------------------------------------
script by Yuhua Chen 8/12/2015
--------------------------------------------------------------------------------------
HELP
    exit 1
}

if [[ "$1" == "-h" || $# -eq 0 ]];
  then
    Help >&2
  fi
#Input Parms
while getopts "h:a:e:t:i:o:s:p:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
   ;;
      a) # Auto-Segmentation path
   ASPATH=$OPTARG
   ;; 
      e) # Extra Output File
   EXTRA_OUTPUT_FILE=$OPTARG
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

mkdir $OUTPUTPATH -p
echo "Writing to ${OUTPUTPATH}/Dice.csv"
if [[ ! -z ${EXTRA_OUTPUT_FILE} ]];then
  echo "Extra Dice Output ${EXTRA_OUTPUT_FILE}"
fi

echo "Image#,MYO_DIST,MYO_DICE,LV_DIST,LV_DICE,AVG_DIST,AVG_DICE,AVG_RO">"${OUTPUTPATH}/Dice.csv"
if [[ ! -z ${EXTRA_OUTPUT_FILE} ]] && [[ ! -f ${EXTRA_OUTPUT_FILE} ]];then
  echo "Path,Image#,MYO_DIST,MYO_DICE,LV_DIST,LV_DICE,AVG_DIST,AVG_DICE,AVG_RO">${EXTRA_OUTPUT_FILE}
fi

for (( i = 1; i <=$ATLASSIZE; i++)) 
  do
    DICE_TXT="${OUTPUTPATH}/Dice_${RESPREF}${i}.txt"
    DICE_CSV="${DICE_TXT}.csv"

    # Dice 
    echo "Calculating ${i}/${ATLASSIZE}"
  	TARGETIMAGE="${INPUTPATH}/label${i}.nii.gz"
    if [[ ! -f ${TARGETIMAGE} ]];then
      TARGETIMAGE="${INPUTPATH}/seg${i}.nii.gz"
    fi
    ASIMG="${ASPATH}/${RESPREF}${i}.nii.gz"
    if [[ ! -f ${ASIMG} ]];then
      ASIMG="${ASPATH}/${RESPREF}${i}_*.nii.gz"
    fi
    echo "Manual: ${TARGETIMAGE}    Segmentation: ${ASIMG}"
  	${ANTSPATH}/ImageMath 3 ${DICE_TXT} DiceAndMinDistSum $TARGETIMAGE ${ASIMG} "${OUTPUTPATH}/MinDist_${RESPREF}${i}.nii.gz"

    # Combine results
    AVG_DIST=( $(cut -d ':' -f2 "${DICE_TXT}"))
    AVG_DICE=( $(cut -d ':' -f3 "${DICE_TXT}"))
    AVG_RO=( $(cut -d ':' -f4 "${DICE_TXT}"))

    DISTANCES=( $(cut -d ',' -f2 "${DICE_CSV}"))
    DICES=( $(cut -d ',' -f3 "${DICE_CSV}"))

    MYO_DIST=${DISTANCES[1]}
    LV_DIST=${DISTANCES[2]}

    MYO_DICE=${DICES[1]}
    LV_DICE=${DICES[2]}
    echo "${i},${MYO_DIST},${MYO_DICE},${LV_DIST},${LV_DICE},${AVG_DIST},${AVG_DICE},${AVG_RO}">>"${OUTPUTPATH}/Dice.csv"
    if [[ ! -z ${EXTRA_OUTPUT_FILE} ]];then
      echo "${ASPATH},${i},${MYO_DIST},${MYO_DICE},${LV_DIST},${LV_DICE},${AVG_DIST},${AVG_DICE},${AVG_RO}">>${EXTRA_OUTPUT_FILE}
    fi    
done

#Timing
end_timeStamp=$(date +"%s")
diff=$(($end_timeStamp-$start_timeStamp))
diff=$(($diff / ${ATLASSIZE}))
echo "$(($diff / 60)) minutes and $(($diff % 60)) seconds elapsed."