#!/bin/bash
ROOT_PATH="/hpc/home/pangjx/4DCMRA/Data/LV/CorretiveLearning/"
OUT_LOG_PATH="/hpc/home/pangjx/4DCMRA/Data/LV/CorretiveLearning/Output/"
for TEMPLATE_ID in 1 2
do
	MS_PATH="${ROOT_PATH}/Atlas/Template${TEMPLATE_ID}"
	AS_PATH="${ROOT_PATH}/Test1/Template${TEMPLATE_ID}"
	OUTPUT_PATH="${ROOT_PATH}/Correction/Template${TEMPLATE_ID}"

	for (( IMG_ID = 1; IMG_ID <= 5; IMG_ID++))
	do
		qsub -j y -o "${OUT_LOG_PATH}" -N "BL_T${TEMPLATE_ID}_I${IMG_ID}" batchCL.sh  ${MS_PATH} ${AS_PATH} ${OUTPUT_PATH} ${IMG_ID}
	done
done
