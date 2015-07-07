TARGETPATH="/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_696"
INPUTPATH="/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1253"
OUTPUTPATH="/home/yuhuachen/WorkingData/reg_1253_to_696"
MASKPATH="/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1253/Mask/LVMask.nii"

mkdir $OUTPUTPATH

NUMBEROFTHREAD=8
TRANSFORMTYPE='s'

REGISTRATIONFLAG=1
USINGMASKFLAG=1

fixedImage="${TARGETPATH}/template.nii"
prefix="${OUTPUTPATH}/reg"
movingImage="${INPUTPATH}/template.nii"
# outputImage="${OUTPUTPATH}/phase${p}.nii"
regCommand="-d 3 -t ${TRANSFORMTYPE} -f ${fixedImage} -m ${movingImage} -o ${prefix} -n ${NUMBEROFTHREAD} "			    
if [[ ${USINGMASKFLAG} -eq 1 ]];then
	regCommand="${regCommand} -x ${MASKPATH}"
fi

if [[ ${REGISTRATIONFLAG} -eq 1 ]]; then
	antsRegistrationSyNQuick.sh $regCommand
fi
movingLabel=${INPUTPATH}/segLV.nii
transCommand="-d 3 --float -f 0 -i ${movingLabel} -o ${OUTPUTPATH}/outputLabel.nii -r ${fixedImage} -n NearestNeighbor  -t ${prefix}1Warp.nii.gz -t ${prefix}0GenericAffine.mat"
antsApplyTransforms ${transCommand}
