ATLAS_SIZE=5
export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"
INPUT_PATH='/hpc/home/pangjx/4DCMRA/Data/LV/Atlas/Set1/'
OUTPUT_PATH='/hpc/home/pangjx/4DCMRA/Data/LV/N4/N4Set1/'
PRESEVED_VALUE=0
MASK_PATH=''
WEIGHT_PATH=''

N4CONVERGENCE="[50x50x50x50,0.0]"
N4SHRINKFACTOR=2

JOB_NAME_PREFIX="N4"

function Help {
    cat <<HELP
Usage:
`basename $0` -i INPUTPATH -o OUTPUTPATH -s ATLASSIZE
Example Case:
`basename $0` -i '/home/yuhuachen/ClusterDir/Data/LV/Atlas/Set1/' -o '/home/yuhuachen/ClusterDir/Data/LV/Atlas/N4Set1/' -s 5
Compulsory arguments:
     -i:  INPUT PATH: path of input images
     -o:  Output Path: path of all corrected images
     -c:  Convergence [iter1xiter2x...xiterN, threshold] default= "[150x150x100x50,0.0]"
     -r:  Preseverd Value within the original range within mask Flag 1/0 (Default = 0)
     -w:  Weighted Image Path
     -p:  Project Job Name
     -s:  atlas size: total number of images (default = 5)
     -x:  Mask image path
--------------------------------------------------------------------------------------
script by Yuhua Chen 7/15/2015
--------------------------------------------------------------------------------------
HELP
    exit 1
}

if [[ "$1" == "-h" || $# -eq 0 ]];
  then
    Help >&2
  fi
#Input Parms
while getopts "h:i:o:s:c:p:x:r:w:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
   ;;
      s) # atlas size
   ATLAS_SIZE=$OPTARG
   ;;
      i) # Input path
   INPUT_PATH=$OPTARG
   ;;
      o) # Output path
   OUTPUT_PATH=$OPTARG
   ;; 
      r) # Mask Path
   PRESEVED_VALUE=$OPTARG
   ;;   
      c) # Convergence
   N4CONVERGENCE=$OPTARG
   ;;      
      x) # Mask Path
   MASK_PATH=$OPTARG
   ;;
      w) # Mask Path
   WEIGHT_PATH=$OPTARG
   ;;
      p) # Output path
   JOB_NAME_PREFIX=$OPTARG
   ;;
     \?) # getopts issues an error message
   echo "$USAGE" >&2
   exit 1
   ;;
  esac
done

function qsubProc(){
  ## 1: Job name
  ## 2: commands
  qsub -cwd -j y -o "${OUTPUT_PATH}" -N ${1} ../wrapper.sh ${2}
}

for t in 1 2
do
	mkdir "${OUTPUT_PATH}/Template${t}" -p
	for ((i = 1; i <= $ATLAS_SIZE; i++))
	do
    MASK_IMG="${MASK_PATH}/Template${t}/mask${i}.nii.gz"
    WEIGTH_IMG="${WEIGHT_PATH}/Template${t}/weight${i}.nii.gz"

		INPUT_IMG="${INPUT_PATH}/Template${t}/img${i}.nii.gz"
		OUTPUT_PREFIX="${OUTPUT_PATH}/Template${t}/img${i}"
		N4CRTCMD="-d 3 -c ${N4CONVERGENCE} -s ${N4SHRINKFACTOR} \
				-i ${INPUT_IMG} -o  [${OUTPUT_PREFIX}.nii.gz, ${OUTPUT_PREFIX}baisFiled.nii.gz] \
				 --verbose -r ${PRESEVED_VALUE}"

		if [[ ! -z ${MASK_PATH} ]]; then
			N4CRTCMD="${N4CRTCMD} -x ${MASK_IMG}"
		fi

    if [[ ! -z ${WEIGHT_PATH} ]]; then
      N4CRTCMD="${N4CRTCMD} -w ${WEIGTH_IMG}"
    fi

		qsubProc "${JOB_NAME_PREFIX}_T${t}I${i}" "${ANTSPATH}/N4BiasFieldCorrection ${N4CRTCMD}"
		echo "Template${t}: ${i}/${ATLAS_SIZE}"
	done
done

