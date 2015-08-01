ATLAS_SIZE=5
INPUT_PATH='/hpc/home/pangjx/4DCMRA/Data/AutoMask/MaskData/'
OUTPUT_PATH='/hpc/home/pangjx/4DCMRA/Data/AutoMask/MaskOutput/'
FIX_PATH_TMP='/hpc/home/pangjx/4DCMRA/Data/LV/Atlas/Set1/Template'

mkdir -p ${OUTPUT_PATH}
for t in 1 2;
do
	for (( i = 1 ; i <= $ATLAS_SIZE; i++ ));
	do
		qsub -cwd -j y -o "${OUTPUT_PATH}" -N "MSK_T${t}i${i}" autoMaskToTargetCluster.sh  -r 1 -t b -f ${FIX_PATH_TMP}${t}/img${i}.nii.gz -i ${INPUT_PATH} -o ${OUTPUT_PATH}/Template${t}/Image${i}/
	done
done