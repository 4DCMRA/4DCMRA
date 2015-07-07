TARGETPHASE=1
INPUTPATH='/home/yuhuachen/WorkingData/InverseTrans/1253/Test3' 
IMGDATAPATH='/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1253'
OUTPUTPATH='/home/yuhuachen/WorkingData/InverseTrans/1253/Test3/Reg2Phase1' 
MASKPATH='/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1253/Mask/LVMask.nii'

mkdir $OUTPUTPATH -p

ATLASSIZE=16
NUMBEROFTHREAD=8
TRANSFORMTYPE='s'

REGISTRATIONFLAG=1
USINGMASKFLAG=1

fixedImage="${IMGDATAPATH}/phase${TARGETPHASE}.nii"
# outputImage="${OUTPUTPATH}/phase${p}.nii"
for (( i = 1 ; i <= $ATLASSIZE; i++ ))
do
	if [[ $i -eq $TARGETPHASE ]]; then
		continue;
	fi
	prefix="${OUTPUTPATH}/reg${i}"
	movingImage="${IMGDATAPATH}/phase${i}.nii"
	regCommand="-d 3 -t ${TRANSFORMTYPE} -f ${fixedImage} -m ${movingImage} -o ${prefix} -n ${NUMBEROFTHREAD} "			    
	if [[ ${USINGMASKFLAG} -eq 1 ]];then
		regCommand="${regCommand} -x ${MASKPATH}"
	fi

	if [[ ${REGISTRATIONFLAG} -eq 1 ]]; then
		antsRegistrationSyNPlus.sh $regCommand
	fi
	movingLabel="${INPUTPATH}/seg${i}.nii.gz"
	outputCandidate="${OUTPUTPATH}/cand${i}.nii.gz"
	transCommand="-d 3 --float -f 0 -i ${movingLabel} -o ${outputCandidate} -r ${fixedImage} -n NearestNeighbor  -t ${prefix}1Warp.nii.gz -t ${prefix}0GenericAffine.mat"
	antsApplyTransforms ${transCommand}

	ATLAS_STR="${ATLAS_STR} ${prefix}Warped.nii.gz " 
    LABEL_STR="${LABEL_STR} ${outputCandidate} "    
    
done

# Label Fusion
fusionLabel="${OUTPUTPATH}/joint.nii" 
jointfusion 3 1 -l $LABEL_STR -g $ATLAS_STR -tg ${fixedImage} ${fusionLabel}
SmoothImage 3 ${fusionLabel} 3 ${fusionLabel} 1 1  
