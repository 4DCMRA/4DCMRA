#!/bin/bash
PHASE_ID_ARRAY=()
MYO_VOLUME_ARRAY=()
LV_VOLUME_ARRAY=()
VOLUME_PATH='/home/yuhuachen/WorkingData/InverseTrans/1253/Manual/Volumes' 
INPUTPATH="/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_1253"

#Input
function Help {
    cat <<HELP
Usage:
`basename $0` -i INPUTDATA -v Volume Path
Example Case:
`basename $0` -i /media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/case_12533 -o /media/yuhuachen/Bill_500G/ProejctData/4DCMRA/LVSeg/DualTemplates/case_1253
Compulsory arguments:
     -i:  Input Data Path of the warped file path
     -v:  Volume path where to store csv files
--------------------------------------------------------------------------------------
script by Yuhua Chen 6/28/2015
--------------------------------------------------------------------------------------
HELP
    exit 1
}

if [[ "$1" == "-h" || $# -eq 0 ]];
  then
    Help >&2
  fi
#Input Parms
while getopts "h:i:v:s:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
   ;;
      i) # transform type
   INPUTPATH=$OPTARG
   ;;
      v) # Volume path
   VOLUME_PATH=$OPTARG
   ;;
      s) # Phase Number
   PHASE_NUMBER=$OPTARG
   ;;
     \?) # getopts issues an error message
   echo "$USAGE" >&2
   exit 1
   ;;
  esac
done

sortIDArray(){
	IFS=$'\n' 
	PHASE_ID_ARRAY=($(sort <<<"${PHASE_ID_ARRAY[*]}"));
}

readCSVData(){
	volumes=( $(cut -d ',' -f2 "${1}"))
	LV_VOLUME_ARRAY+=(${volumes[3]})

	surf=( $(cut -d ',' -f3 "${1}"))
}

extractPhaseId(){
	#Input Arugment
	# $1   filename string
	[[ "${1}" =~ [0-9]+.csv  ]]
	[[ $BASH_REMATCH =~ [0-9]+ ]]
	PHASE_ID=$BASH_REMATCH
	PHASE_ID_ARRAY+=(${PHASE_ID})
}

readAllFile(){
	for f in "${1}/"*.csv;
	do
		extractPhaseId ${f}
		readCSVData ${f}
	done
	PHASE_NUMBER=${#PHASE_ID_ARRAY[@]}

}

print(){
	echo ${PHASE_ID_ARRAY[@]}
	echo ${LV_VOLUME_ARRAY[@]}
	# echo $((join "x" ${LV_VOLUME_ARRAY[@]}))
	VOLUME_STR=$(printf " %d" "${LV_VOLUME_ARRAY[@]}")
	VOLUME_STR=${VOLUME_STR:1}
	echo ${VOLUME_STR}
}

makePhaseGroup1(){
	PHASE_GROUP1=();
	for (( i = 1 ; i <= $PHASE_NUMBER; i ++))
	do
		if [[ ${CLUSTER_ARRAY[$i]} -eq 0 ]];then
			PHASE_GROUP1+=(${PHASE_ID_ARRAY[$i]});
		fi
	done
}

makePhaseGroup2(){
	PHASE_GROUP2=();
	for (( i = 1 ; i <= $PHASE_NUMBER; i ++))
	do
		if [[ ${CLUSTER_ARRAY[$i]} -eq 1 ]]; then
			PHASE_GROUP2+=(${PHASE_ID_ARRAY[$i]});
		fi
	done
}

writeVolumeCSV(){
	echo ${LV_VOLUME_ARRAY[@]} > "${VOLUME_PATH}/LV_volume.csv"
	echo ${PHASE_ID_ARRAY[@]} >> "${VOLUME_PATH}/LV_volume.csv"
}

kmeansCluster(){
	CLUSTER_RESULT=$(python kmeans.py 2 $(eval echo "${LV_VOLUME_ARRAY[@]}"))
	IFS=',' read -a CLUSTER_ARRAY <<< "$CLUSTER_RESULT"
}

writeClusterCSV(){
	makePhaseGroup1
	makePhaseGroup2
	echo ${PHASE_GROUP1[@]} > "${VOLUME_PATH}/LV_phase_groups.csv"
	echo ${PHASE_GROUP2[@]} >> "${VOLUME_PATH}/LV_phase_groups.csv"
}
main(){
readAllFile ${VOLUME_PATH}
kmeansCluster
# writeVolumeCSV
writeClusterCSV
}

main