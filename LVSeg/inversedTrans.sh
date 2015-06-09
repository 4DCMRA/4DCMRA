DATAPATH='/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1253' 
WARPPATH='/home/yuhuachen/WorkingData/UnbiasedTemplate1253' 
OUTPUTPATH='/home/yuhuachen/WorkingData/Output1253/'
PHASENUMBER=16
TEMPLABELIMG=$DATAPATH/segLV.nii

mkdir $OUTPUTPATH

for (( p = 1; p <= $PHASENUMBER; p++))
do
	prefix=$WARPPATH/reg${p}
	outputImage="${OUTPUTPATH}/seg${p}.nii"
    movingImage=$TEMPLABELIMG
    refImage=$TEMPLABELIMG
	antsApplyTransforms -d 3 --float -f 0 -i $movingImage -o $outputImage -r $refImage -t "${prefix}1InverseWarp.nii.gz" -t "[${prefix}0GenericAffine.mat,1]" -n NearestNeighbor
done