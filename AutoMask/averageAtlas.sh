#!bin/bash
ATLAS_SIZE=5
INPUT_PATH='/media/yuhuachen/Document/WorkingData/4DCMRA/LVSegmentation/Cases/case_684/'
OUTPUT_PATH=''

function Help {
    cat <<HELP
Usage:
`basename $0` -i INPUTPATH -o OUTPUTPATH -s ATLASSIZE
Example Case:
`basename $0` -i '/home/yuhuachen/ClusterDir/Data/LV/Atlas/Set1/' -o '/home/yuhuachen/ClusterDir/Data/LV/Atlas/N4Set1/' -s 5
Compulsory arguments:
     -i:  INPUT PATH: path of input images
     -o:  Output Path: path of all corrected images
     -s:  atlas size: total number of images (default = 5)
--------------------------------------------------------------------------------------
script by Yuhua Chen 7/16/2015
--------------------------------------------------------------------------------------
HELP
    exit 1
}

if [[ "$1" == "-h" || $# -eq 0 ]];
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
      s) # atlas size
   ATLAS_SIZE=$OPTARG
   ;;
      i) # Input path
   INPUT_PATH=$OPTARG
   ;;
      o) # Output path
   OUTPUT_PATH=$OPTARG
   ;; 
     \?) # getopts issues an error message
   echo "$USAGE" >&2
   exit 1
   ;;
  esac
done

if

