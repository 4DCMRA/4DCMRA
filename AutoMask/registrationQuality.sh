
#!/bin/bash
# Cross validation
INPUTPATH=/media/yuhuachen/Document/WorkingData/4DCMRA/MaskData
ASPATH=/media/yuhuachen/Document/WorkingData/4DCMRA/MaskData
RESPREF=voting
ATLASSIZE=5
start_timeStamp=$(date +"%s")

function Help {
    cat <<HELP 
Usage:
`basename $0` -i INPUTPATH -o OUTPUTPATH
Example Case:
`basename $0` -i /media/yuhuachen/Document/WorkingData/4DCMRA/AutoMask -a AutoSegmentationPath -o OUTPUTPATH
Compulsory arguments:
     -i:  INPUT PATH: path of ground true images
     -a:  Candidates Path
     -o:  Output Path: path of all test mask files
     	voting : Majority voting
     	joint:	 Joint label fusion
     	joint2:	 2D Joint label fusion
     	STAPLE:  STAPLE, AverageLabels
     	Spatial: Correlation voting
     -s:  atlas size: total number of images (default = 5)
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
while getopts "h:t:i:a:o:s:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
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
      a) # Auto-Segmentation path
   ASPATH=$OPTARG
   ;; 
     \?) # getopts issues an error message
   echo "$USAGE" >&2
   exit 1
   ;;
  esac
done

mkdir $OUTPUTPATH -p

OUTPUT_DICE_CSV="${OUTPUTPATH}/RegDice.csv"
echo "Target#,Image#,MYO_DIST,MYO_DICE,LV_DIST,LV_DICE,AVG_DIST,AVG_DICE,AVG_RO">${OUTPUT_DICE_CSV}
for (( t = 1; t <=$ATLASSIZE; t++))
do
  echo "Target ${t}/${ATLASSIZE}"
  for (( i = 1; i <=$ATLASSIZE; i++)) 
    do
      if [[ ${i} == ${t} ]]; then
        continue;
      fi
      DICE_TXT="${OUTPUTPATH}/Dice_${i}t${t}.txt"
      DICE_CSV="${DICE_TXT}.csv"
      MIN_DIST_IMG="${OUTPUTPATH}/MinDist_${i}t${t}.nii.gz"

      CAND_IMG="${ASPATH}/cand${i}t${t}.nii.gz"

      # Dice 
      echo "Calculating ${i}/${ATLASSIZE}"
    	TARGETIMAGE="${INPUTPATH}/label${t}.nii.gz"
    	${ANTSPATH}/ImageMath 3 ${DICE_TXT} DiceAndMinDistSum $TARGETIMAGE ${CAND_IMG} ${MIN_DIST_IMG}

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
      echo "${t},${i},${MYO_DIST},${MYO_DICE},${LV_DIST},${LV_DICE},${AVG_DIST},${AVG_DICE},${AVG_RO}">>${OUTPUT_DICE_CSV}
  done
done