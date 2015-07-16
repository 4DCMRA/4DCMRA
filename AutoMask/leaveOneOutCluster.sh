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

# N4 Bias Corrected No Mask

ATALS_TEMPLATE="/hpc/home/pangjx/4DCMRA/Data/LV/Atlas/Set1N4NoMask/Template"
ROOT_OUTPUT="/hpc/home/pangjx/4DCMRA/Data/LV/LOO5/"
./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyNRegWOMask/Template1" -p BN4_T1
./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyNRegWOMask/Template2" -p BN4_T2

# N4 Masked with SUSAN
# ATALS_TEMPLATE="/hpc/home/pangjx/4DCMRA/Data/LV/Atlas/Set1N4MaskedSUSAN/Template"
# ROOT_OUTPUT="/hpc/home/pangjx/4DCMRA/Data/LV/LOO4/"
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}1" -o "${ROOT_OUTPUT}/BSyN/Template1" -p BN4SU_T1
# ./autoMask.sh -s 5 -t b -l JointFusion -m ../antsRegistrationSyNPlus.sh -i "${ATALS_TEMPLATE}2" -o "${ROOT_OUTPUT}/BSyN/Template2" -p BN4SU_T2