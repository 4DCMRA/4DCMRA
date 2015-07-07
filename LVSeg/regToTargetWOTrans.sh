TARGETIMG='/home/yuhuachen/WorkingData/MOCO2/template.nii'
INPUTPATH="/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/Atlas"
OUTPUTPATH="/home/yuhuachen/WorkingData/MOCO2/output2"
MASKIMG="/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/Atlas/sumMask.nii"
ATLASSIZE=16

function Help {
    cat <<HELP
Usage:
`basename $0` -i INPUTPATH -t TARGETIMG -o OUTPUTPATH -m MASKIMG
Example Case:
`basename $0` -i /media/yuhuachen/Document/WorkingData/4DCMRA/AutoMask -t a -o temp -e 5 -s ATLASSIZE
Compulsory arguments:
	 -i:  INPUT PATH: path of atlases
	 -s:  Size of Atlas
     -o:  Output Path: path of all output files
     -m:  Mask Image
     -t:  Target Image
--------------------------------------------------------------------------------------
script by Yuhua Chen 6/30/2015
--------------------------------------------------------------------------------------
HELP
    exit 1
}

if [[ "$1" == "-h" || $# -eq 0 ]];
  then
    Help >&2
  fi
#Input Parms
while getopts "h:t:m:i:o:s:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
   ;;
      t) # transform type
   TARGETIMG=$OPTARG
   ;;
      m) # Registration Switch
   MASKIMG=$OPTARG
    ;;
      i) # Input path
   INPUTPATH=$OPTARG
   ;;
   	  s) # Atlas Size
	ATLASSIZE=$OPTARG
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

NUMBEROFTHREAD=8
TRANSFORMTYPE='s'

REGISTRATIONFLAG=1
USINGMASKFLAG=0

fixedImage=$TARGETIMG
# outputImage="${OUTPUTPATH}/phase${p}.nii"
for (( i = 1 ; i <= $ATLASSIZE; i++ ))
do
	prefix="${OUTPUTPATH}/reg${i}"
	movingImage="${INPUTPATH}/phase${i}.nii"
	regCommand="-d 3 -t ${TRANSFORMTYPE} -f ${fixedImage} -m ${movingImage} -o ${prefix} -n ${NUMBEROFTHREAD} "			    
	if [[ ${USINGMASKFLAG} -eq 1 ]];then
		regCommand="${regCommand} -x ${MASKIMG}"
	fi

	if [[ ${REGISTRATIONFLAG} -eq 1 ]]; then
		antsRegistrationSyNPlus.sh $regCommand
	fi
	# movingLabel="${INPUTPATH}/label${i}.nii"
	#outputCandidate="${OUTPUTPATH}/cand${i}.nii"
	#transCommand="-d 3 --float -f 0 -i ${movingLabel} -o ${outputCandidate} -r ${fixedImage} -n NearestNeighbor  -t ${prefix}1Warp.nii.gz -t ${prefix}0GenericAffine.mat"
	#antsApplyTransforms ${transCommand}

	# ATLAS_STR="${ATLAS_STR} ${prefix}Warped.nii " 
 #    LABEL_STR="${LABEL_STR} ${outputCandidate} "    
    
done

# ImageMath 3 "${OUTPUTPATH}/Label.nii.gz" MajorityVoting $LABEL_STR
# # Label Fusion
# case $LABELFUSION in
#   "MajorityVoting")
#     if [[ ! -f "${OUTPUTPATH}/voting${target}.nii.gz" ]];then
#      ImageMath 3 "${OUTPUTPATH}/voting${target}.nii.gz" MajorityVoting $LABEL_STR
#     fi
#     ;;
#   "JointFusion")
#     if [[ ! -f "${OUTPUTPATH}/joint${target}.nii.gz" ]];then
#       jointfusion 3 1 -l $LABEL_STR -g $ATLAS_STR -tg "${INPUTPATH}/img${target}.nii" "${OUTPUTPATH}/joint${target}.nii.gz" 
#       SmoothImage 3 "${OUTPUTPATH}/joint${target}.nii.gz" 3 "${OUTPUTPATH}/joint${target}.nii.gz" 1 1  
#     fi
#     ;;
#   "JointFusion2D")
#     if [[ ! -f "${OUTPUTPATH}/joint2d${target}.nii.gz" ]];then
#       jointfusion 3 1 -l $LABEL_STR -g $ATLAS_STR -tg "${INPUTPATH}/img${target}.nii" -rp 2x2x1 -rs 3x3x1 "${OUTPUTPATH}/joint2d${target}.nii.gz"
#       SmoothImage 3 "${OUTPUTPATH}/joint2d${target}.nii.gz" 3 "${OUTPUTPATH}/joint2d${target}.nii.gz" 1 1  
#     fi
#     ;;  
#   "STAPLE")
#     if [[ ! -f "${OUTPUTPATH}/STAPLE${target}.nii.gz" ]];then
#      ImageMath 3 "${OUTPUTPATH}/STAPLE${target}".nii.gz STAPLE 0.75 $LABEL_STR
#      ImageMath 3 "${OUTPUTPATH}/STAPLE${target}".nii.gz ReplaceVoxelValue "${OUTPUTPATH}/STAPLE${target}0001".nii.gz 0.5 1 1
#      ImageMath 3 "${OUTPUTPATH}/STAPLE${target}".nii.gz ReplaceVoxelValue "${OUTPUTPATH}/STAPLE${target}".nii.gz 0 0.5 0
#      rm "${OUTPUTPATH}/STAPLE${target}0001".nii.gz
#     fi
#     ;;
#   "Spatial")
#     if [[ ! -f "${OUTPUTPATH}/Spatial${target}".nii.gz ]];then
#       ImageMath 3 "${OUTPUTPATH}/Spatial${target}".nii.gz CorrelationVoting "${INPUTPATH}/img${target}".nii $ALTAS_STR  $LABEL_STR
#       SmoothImage 3 "${OUTPUTPATH}/Spatial${target}.nii.gz" 4 "${OUTPUTPATH}/Spatial${target}.nii.gz" 1 1  
#     fi
#     ;;
# esac
# fusionLabel="${OUTPUTPATH}/Label.nii.gz" 
# jointfusion 3 1 -l $LABEL_STR -g $ATLAS_STR -tg ${fixedImage} ${fusionLabel}
# SmoothImage 3 ${fusionLabel} 3 ${fusionLabel} 1 1  
