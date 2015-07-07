DATAPATH='/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1266'
WARPPATH1='/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DualTemplates/case_1266/template1' 
WARPPATH2='/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DualTemplates/case_1266/template2' 
OUTPUTPATH='/home/yuhuachen/WorkingData/InverseTrans/1266/Test4' 

DIVPHASE1=3
DIVPHASE2=15

PHASENUMBER=16

function inverseTrans(){
	# Input Arugment
	# $1 		WrapPath
	# $2 		Phase Array
for  p in $(eval echo "$2")
do
	echo $p
	# TEMPLABELIMG=${1}/segLV.nii.gz
	# prefix=${1}/reg${p}
	# outputImage="${OUTPUTPATH}/seg${p}.nii.gz"
 #    movingImage=$TEMPLABELIMG
 #    refImage=$TEMPLABELIMG
	# antsApplyTransforms -d 3 --float -f 0 -i $movingImage -o $outputImage -r $refImage -t "${prefix}1InverseWarp.nii.gz" -t "[${prefix}0GenericAffine.mat,1]" -n NearestNeighbor
done	
}

mkdir $OUTPUTPATH -p

# PHASE_ARRAY_1="{1..${DIVPHASE1}} {${DIVPHASE2}..${PHASENUMBER}}"
# PHASE_ARRAY_2="{$((${DIVPHASE1}+1))..$((${DIVPHASE2}-1))}"

PHASE_ARRAY_1="${1}"
PHASE_ARRAY_2="${2}"

echo $PHASE_ARRAY_1
echo $PHASE_ARRAY_1

inverseTrans $WARPPATH1 "${PHASE_ARRAY_1}"
inverseTrans $WARPPATH2 "${PHASE_ARRAY_2}"

