# ATALS_TEMPLATE="/hpc/home/pangjx/4DCMRA/Data/LV/Atlas/Set1/Template"
# ROOT_OUTPUT="/hpc/home/pangjx/4DCMRA/Data/LV/LOO2/"

# ./autoMask.sh -s 5 -t s -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/SyN/Template1" -p Syn_T1
# ./autoMask.sh -s 5 -t s -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/SyN/Template2" -p Syn_T2

# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyN/Template1" -p B_T1
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyN/Template2" -p B_T2

# ./autoMask.sh -s 5 -t s -l JointFusion -m ../antsRegistrationSyNPlusAllCC.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/SyNAllCC/Template1" -p CC_T1
# ./autoMask.sh -s 5 -t s -l JointFusion -m ../antsRegistrationSyNPlusAllCC.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/SyNAllCC/Template2" -p CC_T2

# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlusAllCC.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyNAllCC/Template1" -p BCC_T1
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlusAllCC.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyNAllCC/Template2" -p BCC_T2

# N4 Bias Corrected Masked

# ATALS_TEMPLATE="/hpc/home/pangjx/4DCMRA/Data/LV/Atlas/Set1N4Masked/Template"
# ROOT_OUTPUT="/hpc/home/pangjx/4DCMRA/Data/LV/LOO3/"
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyN/Template1" -p BN4_T1
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyN/Template2" -p BN4_T2

# # N4 Bias Corrected Whole Heart Mask R = 0

# ATALS_TEMPLATE="/hpc/home/pangjx/4DCMRA/Data/LV/Atlas/Set1N4WholeHeartMaskedR0/Template"
# ROOT_OUTPUT="/hpc/home/pangjx/4DCMRA/Data/LV/LOO7/"

# # No Hist
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyNRegWOWHMask/Template1" -p BN4R0_T1 -x 0 -j 0
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyNRegWOWHMask/Template2" -p BN4R0_T2 -x 0 -j 0

# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyNRegWHMask/Template1" -p BN4R0WHM_T1 -x 1 -j 0
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyNRegWHMask/Template2" -p BN4R0WHM_T2 -x 1 -j 0

# # Hist
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyNRegWOWHMaskHist/Template1" -p BN4R0J_T1 -x 0 -j 1
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyNRegWOWHMaskHist/Template2" -p BN4R0J_T2 -x 0 -j 1

# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyNRegWHMaskHist/Template1" -p BN4R0WHMJ_T1 -x 1 -j 1
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyNRegWHMaskHist/Template2" -p BN4R0WHMJ_T2 -x 1 -j 1


# # N4 Bias Corrected Whole Heart Mask R = 1
# ATALS_TEMPLATE="/hpc/home/pangjx/4DCMRA/Data/LV/Atlas/Set1N4WholeHeartMaskedR1/Template"
# ROOT_OUTPUT="/hpc/home/pangjx/4DCMRA/Data/LV/LOO8/"

# # No Hist
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyNRegWOWHMask/Template1" -p BN4R1_T1 -x 0 -j 0
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyNRegWOWHMask/Template2" -p BN4R1_T2 -x 0 -j 0

# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyNRegWHMask/Template1" -p BN4R1WHM_T1 -x 1 -j 0
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyNRegWHMask/Template2" -p BN4R1WHM_T2 -x 1 -j 0

# # Hist
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyNRegWOWHMaskHist/Template1" -p BN4R1J_T1 -x 0 -j 1
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyNRegWOWHMaskHist/Template2" -p BN4R1J_T2 -x 0 -j 1

# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyNRegWHMaskHist/Template1" -p BN4R1WHMJ_T1 -x 1 -j 1
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyNRegWHMaskHist/Template2" -p BN4R1WHMJ_T2 -x 1 -j 1


# # N4 Bias Corrected Whole Heart Mask R = 0

# ATALS_TEMPLATE="/hpc/home/pangjx/4DCMRA/Data/LV/Atlas/Set1N4NoMaskR0/Template"
# ROOT_OUTPUT="/hpc/home/pangjx/4DCMRA/Data/LV/LOO6/"

# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyNRegWHMask/Template1" -p LOO6WHM_T1 -x 1 -j 0
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyNRegWHMask/Template2" -p LOO6WHM_T2 -x 1 -j 0

# # Hist

# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyNRegWHMaskHist/Template1" -p LOO6WHMJ_T1 -x 1 -j 1
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyNRegWHMaskHist/Template2" -p LOO6WHMJ_T2 -x 1 -j 1


# # N4 Bias Corrected Whole Heart Mask R = 0

# ATALS_TEMPLATE="/hpc/home/pangjx/4DCMRA/Data/LV/Atlas/Set1N4NoMaskR1/Template"
# ROOT_OUTPUT="/hpc/home/pangjx/4DCMRA/Data/LV/LOO5/"

# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyNRegWHMask/Template1" -p LOO5WHM_T1 -x 1 -j 0
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyNRegWHMask/Template2" -p LOO5WHM_T2 -x 1 -j 0

# # Hist

# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyNRegWHMaskHist/Template1" -p LOO5WHMJ_T1 -x 1 -j 1
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyNRegWHMaskHist/Template2" -p LOO5WHMJ_T2 -x 1 -j 1

# N4 Masked with SUSAN
# ATALS_TEMPLATE="/hpc/home/pangjx/4DCMRA/Data/LV/Atlas/Set1N4MaskedSUSAN/Template"
# ROOT_OUTPUT="/hpc/home/pangjx/4DCMRA/Data/LV/LOO4/"
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyN/Template1" -p BN4SU_T1
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyN/Template2" -p BN4SU_T2

# ATALS_TEMPLATE="/hpc/home/pangjx/4DCMRA/Data/LV/Atlas/Set1/Template"
# MASK_TEMPLATE="/hpc/home/pangjx/4DCMRA/Data/LV/Atlas/Set1/DilatedMasks/Template"
# # INPUT_PATH="/hpc/home/pangjx/4DCMRA/Data/LV/N4/Set1SmoothedMaskAsWeightsR1C3/Template"
# INPUT_PATH="/hpc/home/pangjx/4DCMRA/Data/LV/N4/Exp2/Set1SmoothedMaskAsWeightsR1C2wM/Template"
# ROOT_OUTPUT="/hpc/home/pangjx/4DCMRA/Data/LV/LOO/N4/Exp2/SyNPlus1"

# #./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh  -i "${INPUT_PATH}1" -o "${ROOT_OUTPUT}/BSyN_NoHist/Template1" -p LOONH_T1 -x "${MASK_TEMPLATE}1" -u "${ATALS_TEMPLATE}1" -j 0 -r 1
# #./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh  -i "${INPUT_PATH}2" -o "${ROOT_OUTPUT}/BSyN_NoHist/Template2" -p LOONH_T2 -x "${MASK_TEMPLATE}2" -u "${ATALS_TEMPLATE}2" -j 0 -r 1
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh  -i "${INPUT_PATH}1" -o "${ROOT_OUTPUT}/BSyN_Hist/Template1" -p LOOH_T1 -x "${MASK_TEMPLATE}1" -u "${ATALS_TEMPLATE}1" -j 1 -r 1
# #./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh  -i "${INPUT_PATH}2" -o "${ROOT_OUTPUT}/BSyN_Hist/Template2" -p LOOH_T2 -x "${MASK_TEMPLATE}2" -u "${ATALS_TEMPLATE}2" -j 1 -r 1

ATALS_TEMPLATE="/hpc/home/pangjx/4DCMRA/Data/LV/Atlas/Set1/Template"
MASK_TEMPLATE="/hpc/home/pangjx/4DCMRA/Data/LV/Atlas/Set1/DilatedMasks/Template"
INPUT_PATH="/hpc/home/pangjx/4DCMRA/Data/LV/N4/Exp2/Set1SmoothedMaskAsWeightsR1C2wM/Template"
SUSAN_PATH="/hpc/home/pangjx/4DCMRA/Data/LV/Susan/Exp2/Set1/Template"
LAPLACIAN_PATH=${SUSAN_PATH}

ROOT_OUTPUT="/hpc/home/pangjx/4DCMRA/Data/LV/LOO/NewInit/LOO1/Metric1"
JOBNAME="OldC1R1"
SCRIPT_FILE="../RegScripts/BSyN_metric1.sh"

./autoMask.sh -s 5 -t b -l JointFusion -m ${SCRIPT_FILE} -i "${INPUT_PATH}1" -o "${ROOT_OUTPUT}_NoHist/Template1" -p ${JOBNAME}0_T1 -x "${MASK_TEMPLATE}1" -u "${ATALS_TEMPLATE}1" -q "${SUSAN_PATH}1" -z "${LAPLACIAN_PATH}1" -j 0 
./autoMask.sh -s 5 -t b -l JointFusion -m ${SCRIPT_FILE} -i "${INPUT_PATH}2" -o "${ROOT_OUTPUT}_NoHist/Template2" -p ${JOBNAME}0_T2 -x "${MASK_TEMPLATE}2" -u "${ATALS_TEMPLATE}2" -q "${SUSAN_PATH}2" -z "${LAPLACIAN_PATH}2" -j 0

# ./autoMask.sh -s 5 -t b -l JointFusion -m ${SCRIPT_FILE} -i "${INPUT_PATH}1" -o "${ROOT_OUTPUT}_Hist/Template1" -p ${JOBNAME}1_T1 -x "${MASK_TEMPLATE}1" -u "${ATALS_TEMPLATE}1" -q "${SUSAN_PATH}1" -z "${LAPLACIAN_PATH}1" -j 1 
# ./autoMask.sh -s 5 -t b -l JointFusion -m ${SCRIPT_FILE} -i "${INPUT_PATH}2" -o "${ROOT_OUTPUT}_Hist/Template2" -p ${JOBNAME}1_T2 -x "${MASK_TEMPLATE}2" -u "${ATALS_TEMPLATE}2" -q "${SUSAN_PATH}2" -z "${LAPLACIAN_PATH}2" -j 1

# ROOT_OUTPUT="/hpc/home/pangjx/4DCMRA/Data/LV/LOO/NewInit/LOO2/Metric1"
# JOBNAME="C1"
# SCRIPT_FILE="../RegScripts/BSyN_metric1.sh"

# ./autoMask.sh -s 5 -t b -l JointFusion -m ${SCRIPT_FILE} -i "${INPUT_PATH}1" -o "${ROOT_OUTPUT}/NoHist/Template1" -p ${JOBNAME}0_T1 -x "${MASK_TEMPLATE}1" -u "${ATALS_TEMPLATE}1" -q "${SUSAN_PATH}1" -z "${LAPLACIAN_PATH}1" -j 0 
# ./autoMask.sh -s 5 -t b -l JointFusion -m ${SCRIPT_FILE} -i "${INPUT_PATH}2" -o "${ROOT_OUTPUT}/NoHist/Template2" -p ${JOBNAME}0_T2 -x "${MASK_TEMPLATE}2" -u "${ATALS_TEMPLATE}2" -q "${SUSAN_PATH}2" -z "${LAPLACIAN_PATH}2" -j 0

# ./autoMask.sh -s 5 -t b -l JointFusion -m ${SCRIPT_FILE} -i "${INPUT_PATH}1" -o "${ROOT_OUTPUT}/Hist/Template1" -p ${JOBNAME}1_T1 -x "${MASK_TEMPLATE}1" -u "${ATALS_TEMPLATE}1" -q "${SUSAN_PATH}1" -z "${LAPLACIAN_PATH}1" -j 1 
# ./autoMask.sh -s 5 -t b -l JointFusion -m ${SCRIPT_FILE} -i "${INPUT_PATH}2" -o "${ROOT_OUTPUT}/Hist/Template2" -p ${JOBNAME}1_T2 -x "${MASK_TEMPLATE}2" -u "${ATALS_TEMPLATE}2" -q "${SUSAN_PATH}2" -z "${LAPLACIAN_PATH}2" -j 1

# ROOT_OUTPUT="/hpc/home/pangjx/4DCMRA/Data/LV/LOO/NewInit/LOO2/Metric1_r1"
# JOBNAME="C1r1"
# SCRIPT_FILE="../RegScripts/BSyN_metric1_r1.sh"

# ./autoMask.sh -s 5 -t b -l JointFusion -m ${SCRIPT_FILE} -i "${INPUT_PATH}1" -o "${ROOT_OUTPUT}/NoHist/Template1" -p ${JOBNAME}0_T1 -x "${MASK_TEMPLATE}1" -u "${ATALS_TEMPLATE}1" -q "${SUSAN_PATH}1" -z "${LAPLACIAN_PATH}1" -j 0 
# ./autoMask.sh -s 5 -t b -l JointFusion -m ${SCRIPT_FILE} -i "${INPUT_PATH}2" -o "${ROOT_OUTPUT}/NoHist/Template2" -p ${JOBNAME}0_T2 -x "${MASK_TEMPLATE}2" -u "${ATALS_TEMPLATE}2" -q "${SUSAN_PATH}2" -z "${LAPLACIAN_PATH}2" -j 0

# ./autoMask.sh -s 5 -t b -l JointFusion -m ${SCRIPT_FILE} -i "${INPUT_PATH}1" -o "${ROOT_OUTPUT}/Hist/Template1" -p ${JOBNAME}1_T1 -x "${MASK_TEMPLATE}1" -u "${ATALS_TEMPLATE}1" -q "${SUSAN_PATH}1" -z "${LAPLACIAN_PATH}1" -j 1 
# ./autoMask.sh -s 5 -t b -l JointFusion -m ${SCRIPT_FILE} -i "${INPUT_PATH}2" -o "${ROOT_OUTPUT}/Hist/Template2" -p ${JOBNAME}1_T2 -x "${MASK_TEMPLATE}2" -u "${ATALS_TEMPLATE}2" -q "${SUSAN_PATH}2" -z "${LAPLACIAN_PATH}2" -j 1
