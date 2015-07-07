INPUTPATH='/home/yuhuachen/WorkingData/InverseTrans/1253/Test3'

PHASENUMBER=16

#Input
function Help {
    cat <<HELP
Usage:
`basename $0` -i INPUTDATA 
Example Case:
`basename $0` -i '/home/yuhuachen/WorkingData/InverseTrans/1253/Manual'
     -i:  Input Data Path of segmentation files
     -s:  Number of Phases (Default = 16)
--------------------------------------------------------------------------------------
script by Yuhua Chen 7/1/2015
--------------------------------------------------------------------------------------
HELP
    exit 1
}

if [[ "$1" == "-h" ]];
  then
    Help >&2
  fi
#Input Parms
while getopts "h:i:o:s:" OPT
  do
  case $OPT in
      h) #help
   Help
   exit 0
   ;;
      i) # transform type
   INPUTPATH=$OPTARG
   ;;
      s) # Phase number
   PHASENUMBER=$OPTARG
   ;;   
     \?) # getopts issues an error message
   echo "$USAGE" >&2
   exit 1
   ;;
  esac
done

readCSVData(){
  volumes=( $(cut -d ',' -f2 "${1}"))
  LV_VOLUME_ARRAY+=(${volumes[3]})
  printf "${volumes[3]} "
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
  for f in "${1}/"csv_analysis*.csv;
  do
    extractPhaseId ${f}
    readCSVData ${f}
  done
  PHASE_NUMBER=${#PHASE_ID_ARRAY[@]}

}

writeVolumeCSV(){
  # printf ${LV_VOLUME_ARRAY[@]} 
  echo ${PHASE_ID_ARRAY[@]} > "${VOLUME_PATH}/LV_volume.csv"  
  echo ${LV_VOLUME_ARRAY[@]} >> "${VOLUME_PATH}/LV_volume.csv"

}

makePhaseVolumeCSV(){
  for (( i = 1; i <= $PHASENUMBER; i++ ))
  do
    SEG_IMG=${INPUTPATH}/seg${i}.nii.gz
    if [[ -f $SEG_IMG ]]; then
      printf "%d/%d" $i $PHASENUMBER;
      LabelGeometryMeasures 3 $SEG_IMG " " "${OUTPUTPATH}/csv_analysis${i}.csv"
      printf "           done\n"
    fi
  done
}

main(){
  OUTPUTPATH=$INPUTPATH/Volumes
  VOLUME_PATH=${OUTPUTPATH}

  mkdir $OUTPUTPATH -p

  makePhaseVolumeCSV
  readAllFile ${VOLUME_PATH}
  writeVolumeCSV  
}

main
