PHASESIZE=16
INPUTPATH='/home/yuhuachen/WorkingData/InverseTrans/1253/Test4' 
OUTPUTPATH='/home/yuhuachen/WorkingData/InverseTrans/1253/Test4' 
MANUALPATH='/home/yuhuachen/WorkingData/InverseTrans/1253/Manual'

mkdir $OUTPUTPATH

for (( i = 1 ; i <= $PHASESIZE; i++ ))
do
	TARGETIMAGE="${INPUTPATH}/seg${i}.nii.gz"
	COMPAREIMAGE="${MANUALPATH}/seg${i}.nii.gz"
	ImageMath 3 "${OUTPUTPATH}/Dice${i}.txt" DiceAndMinDistSum $TARGETIMAGE ${COMPAREIMAGE} "${OUTPUTPATH}/MinDist${i}.nii.gz"
done