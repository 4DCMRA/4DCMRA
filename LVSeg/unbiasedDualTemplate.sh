#!/bin/bash
ITERATION=5
INPUTPATH="/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1253"
VOLUME_PATH='/home/yuhuachen/WorkingData/InverseTrans/1253/Test1/Volumes/'
OUTPUTPATH='/media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DualTemplates/case_1253' 

# DIVPHASE1=3
# DIVPHASE2=15
PHASE_ARRAY_1="1 2 3 15 16"
PHASE_ARRAY_2="4 5 6 7 8 9 10 11 12 13 14"
NUMBEROFTHREAD=8
TRANSFORMTYPE='s'
PHASENUMBER=16
REGISTRATIONFLAG=1
function Help {
    cat <<HELP
Usage:
`basename $0` -i INPUTPATH -t TRANSFORMTYPE -o OUTPUTPATH
Example Case:
`basename $0` -i /media/yuhuachen/Document/WorkingData/4DCMRA/AutoMask -t a -o temp
Compulsory arguments:
	   -i:  INPUT PATH: path of input images
     -o:  Output Path: path of all output files
     -s:  Phase Number: total number of phase (default = 16)
     -r:  Registration On/Off: 1 On, 0 Off (default = 1) 
--------------------------------------------------------------------------------------
script by Yuhua Chen 6/25/2015
--------------------------------------------------------------------------------------
HELP
    exit 1
}

if [[ "$1" == "-h" || $# -eq 0 ]];
  then
    Help >&2
  fi
#Input Parms
while getopts "t:h:i:o:s:r:v:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
   ;;
      t) # transform type
   TRANSFORMTYPE=$OPTARG
   ;;
      r) # Registration Switch
    REGISTRATIONFLAG=$OPTARG
    ;;
      s) # Phase Number
   PHASENUMBER=$OPTARG
   ;;
      v) # Phase Number
   VOLUME_PATH=$OPTARG
   ;;   
      i) # Input path
   INPUTPATH=$OPTARG
   ;;
   	  o) # Output path
   OUTPUTPATH=$OPTARG
   ;;
     \?) # getopts issues an error message
   echo "$USAGE" >&2
   exit 1
   ;;
  esac
done

function readGroups() {
  PHASE_GROUP1=( $(cut -d ',' -f1 ${VOLUME_PATH}/LV_phase_groups.csv))
  PHASE_GROUP2=( $(cut -d ',' -f2 ${VOLUME_PATH}/LV_phase_groups.csv))
  echo $({PHASE_GROUP1[@]})
  echo $({PHASE_GROUP2[@]})
}


function computeAvgImage() {
	# Require Input: the number of iteration	
	# Construct Average Image
  # Input Argument
  # $1      Iteration number (from 0 to 5)
  # $2      Template output folder
  # $3      Array of phase
	avgImgStr=" "
	for  p in $(eval echo "$3")
	do
		if [[ "$1" -eq 0 ]]; then
			avgImgStr+=" ${INPUTPATH}/phase${p}.nii"
		else
			avgImgStr+=" ${2}/reg${p}Warped.nii.gz"
		fi		
	done
	#Average the images
  # AverageImages 3 ${2}/avg${1}.nii 1 ${avgImgStr}
}


function computeUnbiasedTemplate(){
  # Compute the unbiased template
  # Input Argument
  # $1      Template ID (0,1,2,...)
  # $2      Array of phase
  
  for (( i = 0; i < ${ITERATION}; i++ ))
  do
    TEMPLATE_OUTPUT_FOLDER="${OUTPUTPATH}/template${1}"
    mkdir $TEMPLATE_OUTPUT_FOLDER -p
    computeAvgImage ${i} ${TEMPLATE_OUTPUT_FOLDER} "${2}"
    avgImage="${TEMPLATE_OUTPUT_FOLDER}/avg${i}.nii"
    #Registration to the average image
    for p in $(eval echo "${2}")
    do
      # echo $p
      fixedImage=$avgImage
      prefix="${TEMPLATE_OUTPUT_FOLDER}/reg${p}"
      movingImage="${INPUTPATH}/phase${p}.nii"
      regCommand="-d 3 -t ${TRANSFORMTYPE} -f ${fixedImage} -m ${movingImage} -o ${prefix} -n ${NUMBEROFTHREAD} "   
      # if [[ ${REGISTRATIONFLAG} -eq 1 ]]; then
      #   if [[ $i -eq ${ITERATION} ]]; then
      #     antsRegistrationSyNPlus.sh $regCommand
      #   else
      #     antsRegistrationSyNQuick.sh $regCommand
      #   fi
      # fi
    done
  done
  # computeAvgImage ${ITERATION} ${TEMPLATE_OUTPUT_FOLDER} "$2"
}

readGroups
# PHASE_ARRAY_1="{1..${DIVPHASE1}} {${DIVPHASE2}..${PHASENUMBER}}"
# PHASE_ARRAY_2="{$((${DIVPHASE1}+1))..$((${DIVPHASE2}-1))}"

# echo $PHASE_ARRAY_1
# echo computeUnbiasedTemplate 1 "${PHASE_ARRAY_1[@]}"
# echo computeUnbiasedTemplate 2 "${PHASE_ARRAY_2[@]}"
# echo $INPUTPATH
# echo $OUTPUTPATH
