TARGETPATH="/home/yuhuachen/WorkingData/UnbiasedTemplate1265/"
INPUTPATH="/home/yuhuachen/WorkingData/UnbiasedTemplate1253/"
OUTPUTPATH="/home/yuhuachen/WorkingData/reg1253to1265"
MASKPATH="/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1253/Mask/LVMask.nii"

mkdir $OUTPUTPATH

NUMBEROFTHREAD=10
TRANSFORMTYPE='s'
REGISTRATIONFLAG=1

fixedImage=${TARGETPATH}/avg5.nii
prefix="${OUTPUTPATH}/reg"
movingImage="${INPUTPATH}/avg5.nii"
# outputImage="${OUTPUTPATH}/phase${p}.nii"
regCommand="-d 3 -t ${TRANSFORMTYPE} -f ${fixedImage} -m ${movingImage} -o ${prefix} -n ${NUMBEROFTHREAD} "			    
if [[ ${REGISTRATIONFLAG} -eq 1 ]]; then
	antsRegistrationSyNPlus.sh $regCommand
fi
