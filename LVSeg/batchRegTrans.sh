#!/bin/bash
INPUTPATH="/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1253"
OUTPUTPATH="/home/yuhuachen/WorkingData/PhaseReg5/"
PHASESIZE=2
NUMBEROFTHREAD=8
movingImage=$INPUTPATH/phase01.nii
MASKIMAGE='/media/yuhuachen/Document/WorkingData/4DCMRA/MaskData/sumMask.nii' 
USINGMASKFLAG=1

mkdir $OUTPUTPATH
segTransformStr="" 

for (( p = 1; p < $PHASESIZE; p++ ))
do
    movingImage="${INPUTPATH}/phase${p}.nii"


	segImage="${OUTPUTPATH}/seglv${p}.nii"
    # if [[ $p -eq 1 ]]; then
    # 	segImage="${INPUTPATH}/seg1.nii"
    # else
    # 	segImage="${OUTPUTPATH}/seg${p}.nii"
    # fi

	fixedImage="${INPUTPATH}/phase$((${p}+1)).nii"
	
	prefix="${OUTPUTPATH}/reg$((${p}+1))"
	regCommand="-d 3 -f ${fixedImage} -m ${movingImage} -o ${prefix} -n ${NUMBEROFTHREAD} "	
	
	if [[ $USINGMASKFLAG -eq 1 ]]; then
		regCommand="${regCommand} -x ${MASKIMAGE} "
	fi
	# # Registration
	antsRegistrationSyNPlus.sh $regCommand
    # Transform Label
    segTransformStr="${segTransformStr} -t ${prefix}1Warp.nii.gz -t ${prefix}0GenericAffine.mat"
    antsApplyTransforms -d 3 --float -f 0 -i $segImage -o "${OUTPUTPATH}/seglv$((${p}+1)).nii" -r $fixedImage -n NearestNeighbor  $segTransformStr
done

# for (( p = 10; p > 0 ; p-- ))
# do
#     movingImage="${INPUTPATH}/phase${p}.nii"

#     if [[ $p -eq 10 ]]; then
#     	segImage="${INPUTPATH}/seg10.nii"
#     else
#     	segImage="${OUTPUTPATH}/seg${p}.nii"
#     fi

# 	fixedImage="${INPUTPATH}/phase$((${p}-1)).nii"
	
# 	prefix="${OUTPUTPATH}/reg$((${p}-1))"
# 	regCommand="-d 3 -t s -f ${fixedImage} -m ${movingImage} -o ${prefix} -n ${NUMBEROFTHREAD} "	
	
# 	if [[ $USINGMASKFLAG -eq 1 ]]; then
# 		regCommand="${regCommand} -x ${MASKIMAGE} "
# 	fi
# 	# # # Registration
# 	# antsRegistrationSyNPlus.sh $regCommand
#     # # Transform Label
#     # antsApplyTransforms -d 3 --float -i $segImage -o "${OUTPUTPATH}/seg$((${p}-1)).nii" -r $segImage -n NearestNeighbor -t "${prefix}1Warp.nii.gz" -t "${prefix}0GenericAffine.mat"
#     # # Transform
#     #antsApplyTransforms -d 3 --float -f 0 -i $movingImage -o "${OUTPUTPATH}/img$((${p}-1)).nii" -r $movingImage  -t "${prefix}1Warp.nii.gz" -t "${prefix}0GenericAffine.mat"
# done

# for (( p = 10; p < $PHASESIZE; p++ ))
# do
#     movingImage="${INPUTPATH}/phase${p}.nii"

#     if [[ $p -eq 10 ]]; then
#     	segImage="${INPUTPATH}/seg10.nii"
#     else
#     	segImage="${OUTPUTPATH}/seg${p}.nii"
#     fi

# 	fixedImage="${INPUTPATH}/phase$((${p}+1)).nii"
	
# 	prefix="${OUTPUTPATH}/reg$((${p}+1))"
# 	regCommand="-d 3 -f ${fixedImage} -m ${movingImage} -o ${prefix} -n ${NUMBEROFTHREAD} "	
	
# 	if [[ $USINGMASKFLAG -eq 1 ]]; then
# 		regCommand="${regCommand} -x ${MASKIMAGE} "
# 	fi
# 	# # Registration
# 	# antsRegistrationSyNPlus.sh $regCommand
#     # # Transform
#     antsApplyTransforms -d 3 --float -f 0 -i $segImage -o "${OUTPUTPATH}/seg$((${p}+1)).nii" -r $fixedImage -n NearestNeighbor  -t "${prefix}1Warp.nii.gz" -t "${prefix}0GenericAffine.mat"
#         # # Transform
#     antsApplyTransforms -d 3 --float -f 0 -i $movingImage -o "${OUTPUTPATH}/img$((${p}+1)).nii" -r $fixedImage  -t "${prefix}1Warp.nii.gz" -t "${prefix}0GenericAffine.mat"
# done