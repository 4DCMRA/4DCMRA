ATLAS_SIZE=5
export ANTSPATH="/hpc/apps/ants/2.1.0-devel/bin"
export FSLDIR="/hpc/apps/fsl/5.0.4/"

INPUT_PATH='/hpc/home/pangjx/4DCMRA/Data/LV/Atlas/Set1/'
OUTPUT_PATH='/hpc/home/pangjx/4DCMRA/Data/LV/N4/N4Set1/'

BT=35
DT=2
JOB_NAME_PREFIX="Su"

function Help {
    cat <<HELP
Usage:
`basename $0` -i INPUTPATH -o OUTPUTPATH -s ATLASSIZE
Example Case:
`basename $0` -i '/home/yuhuachen/ClusterDir/Data/LV/Atlas/Set1/' -o '/home/yuhuachen/ClusterDir/Data/LV/Atlas/N4Set1/' -s 5
Compulsory arguments:
     -i:  INPUT PATH: path of input images
     -o:  Output Path: path of all corrected images
     -r: is spatial size (sigma, i.e., half-width) of smoothing, in mm.
     -P:  Project Job Name
     -s:  atlas size: total number of images (default = 5)
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
while getopts "h:i:o:s:p:x:r:" OPT
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
      r) # sigma
   DT=$OPTARG
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
		INPUT_IMG="${INPUT_PATH}/Template${t}/img${i}.nii.gz"
		OUTPUT_PREFIX="${OUTPUT_PATH}/Template${t}/susan${i}"
		N4CRTCMD=" ${INPUT_IMG} ${BT} ${DT} 3 1 0 ${OUTPUT_PREFIX}.nii.gz "

		qsubProc "${JOB_NAME_PREFIX}_T${t}I${i}" "${FSLDIR}/bin/susan ${N4CRTCMD}"
		echo "Template${t}: ${i}/${ATLAS_SIZE}"
	done
done

